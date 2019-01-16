module SmbRpc
  class Lsarpc < Rpc

    attr_accessor :accountHandle

    class LsarOpenAccountReq < BinData::Record
      endian :little
      request :request
      string :policyHandle, :length => 20
      uint32 :sub_auth, :value => lambda { accountSid.subAuthorityCount.value }
      rpc_sid :accountSid
      uint32 :desiredAccess

      def initialize_instance
        super
        policyHandle.value = get_parameter(:handle)
        desiredAccess.value = get_parameter(:access)
        sid = get_parameter(:sid)
        sidArray = sid.split("-")
        subAuthorityCount = sidArray.size - 3
        accountSid.revision.value = sidArray[1].to_i
        accountSid.subAuthorityCount.value = subAuthorityCount
        accountSid.identifierAuthority.value = [sidArray[2].to_i].pack("N").rjust(6, "\x00")
        subAuthorityCount.times do |i|
          accountSid.subAuthority[i] = sidArray[i + 3].to_i
        end
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 17        #LsarOpenAccount
      end
    end

    class LsarOpenAccountRes < BinData::Record
      endian :little
      response :response
      string :accountHandle, :length => 20
      uint32 :windowsError
    end

    def openAccount(desiredAccess:, sid:)
      lsarOpenAccountReq = LsarOpenAccountReq.new(handle:@policyHandle, access:desiredAccess, sid:sid)
      lsarOpenAccountRes = @file.ioctl_send_recv(lsarOpenAccountReq).buffer
      lsarOpenAccountRes.raise_not_error_success("openAccount")
      lsarOpenAccountRes = LsarOpenAccountRes.read(lsarOpenAccountRes)
      @accountHandle = lsarOpenAccountRes.accountHandle
      return self
    end

end
end
