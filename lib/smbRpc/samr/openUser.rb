module SmbRpc
  class Samr < Rpc

    class SamrOpenUserReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      uint32 :desiredAccess
      uint32 :userId

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        desiredAccess.value = get_parameter(:access)
        userId.value = get_parameter(:uid)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 34        #SamrOpenUser
      end
    end

    class SamrOpenUserRes < BinData::Record
      endian :little
      request :request
      string :userHandle, :length => 20
      uint32 :windowsError
    end

    def openUser(userId:, desiredAccess:SAMR_COMMON_ACCESS_MASK["MAXIMUM_ALLOWED"])
      samrOpenUserReq = SamrOpenUserReq.new(uid:userId, access:desiredAccess, handle:@domainHandle)
      samrOpenUserRes = @file.ioctl_send_recv(samrOpenUserReq).buffer
      samrOpenUserRes.raise_not_error_success("openUser")
      samrOpenUserRes = SamrOpenUserRes.read(samrOpenUserRes)
      @userHandle = samrOpenUserRes.userHandle
      return self
    end

end
end

