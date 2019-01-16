module SmbRpc
  class Samr < Rpc

    class SamrCreateAliasInDomainReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      rpc_unicode_string :accountName 		#declared in lsarpc/lsaQueryInformationPolicy.rb
      conformantandVaryingStrings :accountNameNdr
      uint32 :desiredAccess

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        accountNameNdr.str = get_parameter(:aliasName).bytes.pack("v*")
        numBytes = accountNameNdr.actual_count * 2
        accountName.len.value = numBytes
        accountName.maximumLength.value = numBytes
        desiredAccess.value = get_parameter(:access)

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 14        	#SamrCreateAliasInDomain
      end
    end

    class SamrCreateAliasInDomainRes < BinData::Record
      endian :little
      request :request
      string :aliasHandle, :length => 20
      uint32 :relativeId
      uint32 :windowsError
    end

    def createAliasInDomain(name:, desiredAccess:SAMR_ALIAS_ACCESS_MASK["ALIAS_ALL_ACCESS"])
      samrCreateAliasInDomainReq = SamrCreateAliasInDomainReq.new(aliasName:name, access:desiredAccess, handle:@domainHandle)
      samrCreateAliasInDomainRes = @file.ioctl_send_recv(samrCreateAliasInDomainReq).buffer
      samrCreateAliasInDomainRes.raise_not_error_success("createAliasInDomain")
      samrCreateAliasInDomainRes = SamrCreateAliasInDomainRes.read(samrCreateAliasInDomainRes)
      @aliasHandle = samrCreateAliasInDomainRes.aliasHandle
      return self
      end

end
end

