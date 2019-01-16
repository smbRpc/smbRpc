module SmbRpc
  class Srvsvc < Rpc

    class NetrServerGetInfoReq < BinData::Record
      endian :little
      request :request
      uint32 :ref_id_unc, :value => 1
      conformantandVaryingStrings :serverName
      uint32 :level, :value => 101

      def initialize_instance
        super
        serverName.str = "\\\\#{get_parameter(:srvName)}\x00".bytes.pack("v*")
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 21	#NetrServerGetInfo
      end
    end

    class Server_info_101 < BinData::Record
      endian :little
      uint32 :sv101_platform_id
      uint32 :ref_id_name
      uint32 :sv101_version_major
      uint32 :sv101_version_minor
      uint32 :serverType
      uint32 :ref_id_comment
      conformantandVaryingStrings :nameNdr
      conformantandVaryingStrings :commentNdr
    end

    class NetrServerGetInfoRes < BinData::Record
      endian :little
      response :response
      uint32 :switch
      uint32 :ref_id_infoStruct
      server_info_101 :infoStruct
      uint32 :windowsError
    end

    def serverGetInfo(serverName:@ip)
      netrServerGetInfoReq = NetrServerGetInfoReq.new(:srvName=> serverName)
      netrServerGetInfoRes = @file.ioctl_send_recv(netrServerGetInfoReq).buffer
      netrServerGetInfoRes.raise_not_error_success("serverGetInfo")
      netrServerGetInfoRes = NetrServerGetInfoRes.read(netrServerGetInfoRes)
      info = netrServerGetInfoRes.infoStruct
      h = { :platform_id => info.sv101_platform_id,
            :version_major => info.sv101_version_major,
            :version_minor => info.sv101_version_minor,
            :type => info.serverType,
            :name => info.nameNdr.str.unpack("v*").pack("c*").chop, 
            :comment => info.commentNdr.str.unpack("v*").pack("c*").chop 
      }
      return h
    end
end
end

