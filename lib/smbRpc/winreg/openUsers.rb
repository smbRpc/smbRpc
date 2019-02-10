module SmbRpc
  class Winreg < Rpc

    class OpenUsersReq < BinData::Record
      endian :little
      request :request
      uint32 :serverName
      uint32 :samDesired

      def initialize_instance
        super
        samDesired.value = get_parameter(:access)

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 4        #OpenUsers
      end
    end

    class OpenUsersRes < BinData::Record
      endian :little
      request :request
      string :phKey, :length => 20
      uint32 :windowsError
    end

    def openUsers(samDesired:WINREG_REGSAM["MAXIMUM_ALLOWED"])
      openUsersReq = OpenUsersReq.new(access:samDesired)
      openUsersRes = @file.ioctl_send_recv(openUsersReq).buffer
      openUsersRes.raise_not_error_success("openUsers")
      openUsersRes = OpenUsersRes.read(openUsersRes)
      @rootKeyHandle = openUsersRes.phKey
      return self
    end

end
end

