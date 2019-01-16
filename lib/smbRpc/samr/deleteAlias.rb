module SmbRpc
  class Samr < Rpc

    class SamrDeleteAliasReq < BinData::Record
      endian :little
      request :request
      string :aliasHandle, :length => 20

      def initialize_instance
        super
        aliasHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 30        #SamrDeleteAlias
      end
    end

    class SamrDeleteAliasRes < BinData::Record
      endian :little
      request :request
      string :aliasHandle, :length => 20
      uint32 :windowsError
    end

    def deleteAlias
      samrDeleteAliasReq = SamrDeleteAliasReq.new(handle:@aliasHandle)
      samrDeleteAliasRes = @file.ioctl_send_recv(samrDeleteAliasReq).buffer
      samrDeleteAliasRes.raise_not_error_success("deleteAlias")
      samrDeleteAliasRes = SamrDeleteAliasRes.read(samrDeleteAliasRes)
      @aliasHandle = nil
      return 0
    end

end
end

