module SmbRpc
  class Svcctl < Rpc
    class CloseServiceHandleReq < BinData::Record	#use to close BOTH SC and service handle
      endian :little
      request :request
      string :serviceHandle, :length => 20

      def initialize_instance
        super
        serviceHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 0        			#RCloseServiceHandle
      end
    end

    class CloseServiceHandleRes < BinData::Record
      endian :little
      request :request
      string :serviceHandle, :length => 20
      uint32 :windowsError
    end

    def closeService()
      if !@serviceHandle.nil?   #close service handle if exist
        closeServiceHandleReq = CloseServiceHandleReq.new(handle:@serviceHandle)
        closeServiceHandleRes = @file.ioctl_send_recv(closeServiceHandleReq).buffer
        closeServiceHandleRes.raise_not_error_success("closeService")
        @serviceHandle = nil
      end
    end

    def closeScm()
      if !@scHandle.nil?        #close SC handle if exist
        closeServiceHandleReq = CloseServiceHandleReq.new(handle:@scHandle)
        closeServiceHandleRes = @file.ioctl_send_recv(closeServiceHandleReq).buffer
        closeServiceHandleRes.raise_not_error_success("closeScm")
        @serviceHandle = nil
      end
    end

    def close()
      closeService()
      closeScm()
      super
    end

end
end
