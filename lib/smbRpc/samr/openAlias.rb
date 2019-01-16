module SmbRpc
  class Samr < Rpc

    class SamrOpenAliasReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      uint32 :desiredAccess
      uint32 :aliasId

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        desiredAccess.value = get_parameter(:access)
        aliasId.value = get_parameter(:aid)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 27        #SamrOpenAlias
      end
    end

    class SamrOpenAliasRes < BinData::Record
      endian :little
      request :request
      string :aliasHandle, :length => 20
      uint32 :windowsError
    end

    def openAlias(aliasId:, desiredAccess:SAMR_COMMON_ACCESS_MASK["MAXIMUM_ALLOWED"])
      samrOpenAliasReq = SamrOpenAliasReq.new(aid:aliasId, access:desiredAccess, handle:@domainHandle)
      samrOpenAliasRes = @file.ioctl_send_recv(samrOpenAliasReq).buffer
      samrOpenAliasRes.raise_not_error_success("openAlias")
      samrOpenAliasRes = SamrOpenAliasRes.read(samrOpenAliasRes)
      @aliasHandle = samrOpenAliasRes.aliasHandle
      return self
    end

end
end

