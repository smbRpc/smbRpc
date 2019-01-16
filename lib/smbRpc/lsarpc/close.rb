
module SmbRpc
  class Lsarpc < Rpc

    class LsarCloseReq < BinData::Record
      endian :little
      request :request
      string :objectHandle, :length => 20
      def initialize_instance
        super
        objectHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 0        #LsarClose
      end
    end

    class LsarCloseRes < BinData::Record
      endian :little
      request :request
      string :objectHandle, :length => 20
      uint32 :windowsError
    end

    def closePolicy()
      if !@policyHandle.nil?
        lsarCloseReq = LsarCloseReq.new(handle:@policyHandle)
        lsarCloseRes = @file.ioctl_send_recv(lsarCloseReq).buffer
        lsarCloseRes.raise_not_error_success("closeAccount")
        @policyHandle = nil
      end
    end

    def closeAccount()
      if !@accountHandle.nil?
        lsarCloseReq = LsarCloseReq.new(handle:@accountHandle)
        lsarCloseRes = @file.ioctl_send_recv(lsarCloseReq).buffer
        lsarCloseRes.raise_not_error_success("closeAccount")
        @accountHandle = nil
      end
    end

    def close()
      closeAccount()      
      closePolicy()      
      super
    end
end
end
