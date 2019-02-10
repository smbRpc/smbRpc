module SmbRpc
  class Winreg < Rpc

    class OpenCurrentUserReq < BinData::Record
      endian :little
      request :request
      uint32 :serverName
      uint32 :samDesired

      def initialize_instance
        super
        samDesired.value = get_parameter(:access)

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 1        #OpenCurrentUser
      end
    end

    class OpenCurrentUserRes < BinData::Record
      endian :little
      request :request
      string :phKey, :length => 20
      uint32 :windowsError
    end

    def openCurrentUser(samDesired:WINREG_REGSAM["MAXIMUM_ALLOWED"])
      openCurrentUserReq = OpenCurrentUserReq.new(access:samDesired)
      openCurrentUserRes = @file.ioctl_send_recv(openCurrentUserReq).buffer
      openCurrentUserRes.raise_not_error_success("openCurrentUser")
      openCurrentUserRes = OpenCurrentUserRes.read(openCurrentUserRes)
      @rootKeyHandle = openCurrentUserRes.phKey
      return self
    end

end
end

