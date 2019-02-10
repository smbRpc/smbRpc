module SmbRpc
  class Winreg < Rpc

    class OpenLocalMachineReq < BinData::Record
      endian :little
      request :request
      uint32 :serverName
      uint32 :samDesired

      def initialize_instance
        super
        samDesired.value = get_parameter(:access)

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 2        #OpenLocalMachine
      end
    end

    class OpenLocalMachineRes < BinData::Record
      endian :little
      request :request
      string :phKey, :length => 20
      uint32 :windowsError
    end

    def openLocalMachine(samDesired:WINREG_REGSAM["MAXIMUM_ALLOWED"])
      openLocalMachineReq = OpenLocalMachineReq.new(access:samDesired)
      openLocalMachineRes = @file.ioctl_send_recv(openLocalMachineReq).buffer
      openLocalMachineRes.raise_not_error_success("openLocalMachine")
      openLocalMachineRes = OpenLocalMachineRes.read(openLocalMachineRes)
      @rootKeyHandle = openLocalMachineRes.phKey
      return self
    end

end
end

