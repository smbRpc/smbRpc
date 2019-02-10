module SmbRpc
  class Winreg < Rpc

    class OpenCurrentConfigReq < BinData::Record
      endian :little
      request :request
      uint32 :serverName
      uint32 :samDesired

      def initialize_instance
        super
        samDesired.value = get_parameter(:access)

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 27        #OpenCurrentConfig
      end
    end

    class OpenCurrentConfigRes < BinData::Record
      endian :little
      request :request
      string :phKey, :length => 20
      uint32 :windowsError
    end

    def openCurrentConfig(samDesired:WINREG_REGSAM["MAXIMUM_ALLOWED"])
      openCurrentConfigReq = OpenCurrentConfigReq.new(access:samDesired)
      openCurrentConfigRes = @file.ioctl_send_recv(openCurrentConfigReq).buffer
      openCurrentConfigRes.raise_not_error_success("openCurrentConfig")
      openCurrentConfigRes = OpenCurrentConfigRes.read(openCurrentConfigRes)
      @rootKeyHandle = openCurrentConfigRes.phKey
      return self
    end

end
end

