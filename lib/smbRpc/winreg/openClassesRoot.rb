module SmbRpc
  class Winreg < Rpc

    class OpenClassesRootReq < BinData::Record
      endian :little
      request :request
      uint32 :serverName
      uint32 :samDesired

      def initialize_instance
        super
        samDesired.value = get_parameter(:access)

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 0        #OpenClassesRoot
      end
    end

    class OpenClassesRootRes < BinData::Record
      endian :little
      request :request
      string :phKey, :length => 20
      uint32 :windowsError
    end

    def openClassesRoot(samDesired:WINREG_REGSAM["MAXIMUM_ALLOWED"])
      openClassesRootReq = OpenClassesRootReq.new(access:samDesired)
      openClassesRootRes = @file.ioctl_send_recv(openClassesRootReq).buffer
      openClassesRootRes.raise_not_error_success("openClassesRoot")
      openClassesRootRes = OpenClassesRootRes.read(openClassesRootRes)
      @rootKeyHandle = openClassesRootRes.phKey
      return self
    end

end
end

