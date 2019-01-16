module SmbRpc
  class Epmapper < Rpc
    #https://svn.nmap.org/nmap-exp/drazen/var/IDL/epmapper.idl?p=25000
    class Epm_LookupReq < BinData::Record
      endian :little
      request :request
      uint32 :inquiry_type, :value => 0x0f
      uint32 :object
      uint32 :interface_id
      uint32 :vers_option
      string :entry_handle, :length => 20
      uint32 :max_ents, :value => 1

      def initialize_instance
        super
        entry_handle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 2        #epm_Lookup
      end
    end

    class Epm_floor < BinData::Record
      endian :little
      uint16 :lhsLength
      uint8 :protocol
      string :lhs_data, :length => lambda { lhsLength - 1 }
      uint16 :rhsLength
      string :rhs_data, :length => :rhsLength
    end

    class Epm_LookupRes < BinData::Record
      endian :little
      response :response
      string :entry_handle, :length => 20
      uint32 :num_ents

      #epm_entry_t
      uint32 :max_count
      uint32 :offset
      uint32 :actual_count
      string :guid, :length => 16
      uint32 :ref_id_tower
      uint32 :annotation_offset
      uint32 :annotation_length
      choice :annotation, :selection => :annotation_length do
        uint32 1 
        string :default, :length => :annotation_length
      end

      #16 byte align
      string :pad, :onlyif => lambda { annotation_length > 1 }, :length => lambda { (4 - ( annotation_length % 4 )) % 4  }

      #epm_twr_t
      uint32 :tower_length
      uint32 :tower_len
      uint16 :num_floors
      array :floors, :type => :epm_floor, :initial_length => :num_floors
      uint32 :windowsError
    end

    def epmLookup()
      @handle = "\x00"*20
      out = []
      loop do
        epm_LookupReq = Epm_LookupReq.new(handle:@handle)
        epm_LookupRes = @file.ioctl_send_recv(epm_LookupReq).buffer
        result = epm_LookupRes[-4,4].unpack("V")[0]
        break if result == 0x16c9a0d6	#[MS-RPCE] There are no elements that satisfy the specified search criteria
        epm_LookupRes.raise_not_error_success("epmLookup")
        #https://msdn.microsoft.com/en-us/library/cc243786.aspx
        #RPC over SMB MUST use a protocol identifier of 0x0F instead of 0x10, as specified in [C706] Appendix I.<4>
        epm_LookupRes = Epm_LookupRes.read(epm_LookupRes)
        h = {}
        epm_LookupRes.floors.each do |e|
          h[:uuid] = "%s.%i"%[uuidParse(e.lhs_data), e.rhs_data.unpack("v")[0]] if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_UUID"]
          h[:ndr] = "%s.%i"%[uuidParse(e.lhs_data), e.rhs_data.unpack("v")[0]] if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_UUID"] && h.has_key?(:uuid)
          h[:name_pipe] = "%s"%[e.rhs_data.gsub("\x00","")] if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_NAMED_PIPE"]
          h[:smb] = "%s"%[e.rhs_data.gsub("\x00","")] if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_SMB"]
          h[:netBios] = "%s"%[e.rhs_data.gsub("\x00","")] if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_NETBIOS"]
          h[:ip] = "%s"%[e.rhs_data.unpack("c*").join(".")] if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_IP"]
          h[:port] = "%i"%[e.rhs_data.unpack("v")[0]] if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_TCP"]
          h[:ncalrpc] = true if e.protocol == EPM_PROTOCOL["EPM_PROTOCOL_NCALRPC"]
        end
        out << h
        @handle = epm_LookupRes.entry_handle
      end
      return out
    end

    def uuidParse(uuidBin)
      return "%s-%s-%s-%s-%s %i"%[uuidBin[0,4].b.reverse.unpack("H*")[0], 
        uuidBin[4,2].b.reverse.unpack("H*")[0], uuidBin[6,2].b.reverse.unpack("H*")[0], 
        uuidBin[8,2].unpack("H*")[0], uuidBin[10,6].unpack("H*")[0], uuidBin[16,2].unpack("v")[0]]
    end

end
end

