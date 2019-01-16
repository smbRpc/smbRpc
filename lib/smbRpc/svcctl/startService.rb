module SmbRpc
  class Svcctl < Rpc

    class StartServiceReq  < BinData::Record
      mandatory_parameter :handle
      endian :little
      request :request
      string :serviceHandle, :length => 20
      uint32 :argc
      uint32 :argv

      def initialize_instance
        super
        serviceHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 19        #RStartServiceW
      end
    end

    class StartServiceRes  < BinData::Record
      endian :little
      request :response
      uint32 :windowsError
    end

    def startService()
      startServiceReq = StartServiceReq.new(handle:@serviceHandle)
      startServiceRes = @file.ioctl_send_recv(startServiceReq).buffer
      startServiceRes.raise_not_error_success("startService")
      return 0
    end

end
end

