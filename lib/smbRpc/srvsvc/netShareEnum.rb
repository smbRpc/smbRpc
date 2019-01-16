module SmbRpc
  class Srvsvc < Rpc

    class Share_info_0 < BinData::Record
      endian :little
      uint32 :ref_id_shi0_netname, :initial_value => 1
      uint32 :max_count
      array :ref_id_array, :type => :uint32, :initial_length => :max_count
      array :conformantandVaryingStringsArray, :type => :conformantandVaryingStrings, :initial_length => :max_count
    end

    class Share_info_0_container < BinData::Record
      endian :little
      uint32 :entriesRead
      choice :share_info_entries, :selection => :entriesRead do
        uint32 0
        share_info_0 :default
      end
    end

    class NetnameRemark < BinData::Record
      endian :little
      conformantandVaryingStrings :netname
      conformantandVaryingStrings :remark
    end

    class Share_info_1 < BinData::Record
      endian :little
      uint32 :ref_id_shi1_netname, :initial_value => 1
      uint32 :max_count
      array :ref_id_netname, :type => :uint32, :initial_length => :max_count
      array :shi1_type, :type => :uint32, :initial_length => :max_count
      array :ref_id_remark, :type => :uint32, :initial_length => :max_count
      array :netname_remark, :type => :netnameRemark, :initial_length => :max_count
    end

    class Share_info_1_container < BinData::Record
      endian :little
      uint32 :entriesRead, :initial_value => 0
      choice :share_info_entries, :selection => :entriesRead do
        uint32 0
        share_info_1 :default
      end
    end

    class Share_enum_struct < BinData::Record
      endian :little
      uint32 :level
      uint32 :share_enum_union_tag, :initial_value => :level
      uint32 :ref_id_share_info_container, :initial_value => 1
      choice :share_info_container, :selection => :level do
        share_info_0_container 0
        share_info_1_container 1
      end
    end

    class NetShareEnumReq < BinData::Record
      endian :little
      request :request
      uint32 :ref_id_unc, :value => 1
      conformantandVaryingStrings :serverName
      share_enum_struct :share_enum_struct
      uint32 :max_buffer, :initial_value => 0xffffffff
      uint32 :ref_id_resume, :initial_value => 1    #unique pointer(can have null)
      uint32 :resume_handle, :initial_value => 0

      def initialize_instance
        super
        serverName.str = "\\\\#{get_parameter(:srvName)}\x00".bytes.pack("v*")
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 15
        share_enum_struct.level = get_parameter(:shareLevel)
      end
    end

    class NetShareEnumRes < BinData::Record
      endian :little
      response :response
      share_enum_struct :share_enum_struct
      uint32 :totalEntries
      uint32 :ref_id_resume
      uint32 :resume_handle
      uint32 :windowsError
    end

    def netShareEnum(serverName:@ip)
      shareEnumReq = NetShareEnumReq.new(:srvName=> serverName, shareLevel:1)
      shareEnumRes = @file.ioctl_send_recv(shareEnumReq).buffer
      shares = NetShareEnumRes.read(shareEnumRes)
      out = []
      numShare = shares.share_enum_struct.share_info_container.entriesRead
      shi1_container = shares.share_enum_struct.share_info_container
      numShare.times do |i|
        type =  shi1_container.share_info_entries.shi1_type[i]
        shareName = shi1_container.share_info_entries.netname_remark[i].netname.str.unpack("v*").pack("c*").chop
        remark = shi1_container.share_info_entries.netname_remark[i].remark.str.unpack("v*").pack("c*").chop
        out << {shareName:shareName, remark:remark, type:type}
      end
      return out
    end

end
end

