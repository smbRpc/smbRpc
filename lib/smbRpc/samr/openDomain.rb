module SmbRpc
  class Samr < Rpc

    class SamrOpenDomainReq < BinData::Record
      endian :little
      request :request
      string :serverHandle, :length => 20
      uint32 :desiredAccess
      sid_element :domainId		#declared in lsarpc/lsaEnumerateAccounts.rb

      def initialize_instance
        super
        serverHandle.value = get_parameter(:handle)
        desiredAccess.value = get_parameter(:access)
        sid = get_parameter(:sid)
        sidArray = sid.split("-")
        subAuthorityCount = sidArray.size - 3
        domainId.sub_auth.value = subAuthorityCount
        domainId.sid.revision.value = sidArray[1].to_i
        domainId.sid.subAuthorityCount.value = subAuthorityCount
        domainId.sid.identifierAuthority.value = [sidArray[2].to_i].pack("N").rjust(6, "\x00")
        subAuthorityCount.times do |i|
          domainId.sid.subAuthority[i] = sidArray[i + 3].to_i
        end
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 7        #SamrOpenDomain
      end
    end

    class SamrOpenDomainRes < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      uint32 :windowsError
    end

    def openDomain(domainSid:, desiredAccess:SAMR_COMMON_ACCESS_MASK["MAXIMUM_ALLOWED"])
      samrOpenDomainReq = SamrOpenDomainReq.new(sid:domainSid, access:desiredAccess, handle:@serverHandle)
      samrOpenDomainRes = @file.ioctl_send_recv(samrOpenDomainReq).buffer
      samrOpenDomainRes.raise_not_error_success("openDomain")
      samrOpenDomainRes = SamrOpenDomainRes.read(samrOpenDomainRes)
      @domainHandle = samrOpenDomainRes.domainHandle
      return self
    end

end
end

