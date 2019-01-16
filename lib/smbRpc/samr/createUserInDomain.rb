module SmbRpc
  class Samr < Rpc

    class SamrCreateUser2InDomainReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      rpc_unicode_string :name 		#declared in lsarpc/lsaQueryInformationPolicy.rb
      conformantandVaryingStrings :nameNdr
      uint32 :accountType
      uint32 :desiredAccess

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        nameNdr.str = get_parameter(:accName).bytes.pack("v*")
        numBytes = nameNdr.actual_count * 2
        name.len.value = numBytes
        name.maximumLength.value = numBytes
        accountType.value = get_parameter(:accType)
        desiredAccess.value = get_parameter(:access)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 50        #SamrCreateUser2InDomain
      end
    end

    class SamrCreateUser2InDomainRes < BinData::Record
      endian :little
      request :request
      string :userHandle, :length => 20
      uint32 :grantedAccess
      uint32 :relativeId
      uint32 :windowsError
    end

    def createUserInDomain(name:, accountType:SAMR_CREATE_USER_ACCOUNT["USER_NORMAL_ACCOUNT"],
        desiredAccess:SAMR_USER_ACCESS_MASK["USER_ALL_ACCESS"])
      samrCreateUser2InDomainReq = SamrCreateUser2InDomainReq.new(accName:name, accType:accountType, access:desiredAccess, handle:@domainHandle)
      samrCreateUser2InDomainRes = @file.ioctl_send_recv(samrCreateUser2InDomainReq).buffer
      samrCreateUser2InDomainRes.raise_not_error_success("createUserInDomain")
      samrCreateUser2InDomainRes = SamrCreateUser2InDomainRes.read(samrCreateUser2InDomainRes)
      @userHandle = samrCreateUser2InDomainRes.userHandle
      return self
      end

end
end

