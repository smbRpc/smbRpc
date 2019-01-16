
module SmbRpc
  class Samr < Rpc

    class SamrCloseHandleReq < BinData::Record
      endian :little
      request :request
      string :samHandle, :length => 20
      def initialize_instance
        super
        samHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 1        #SamrCloseHandle
      end
    end

    class SamrCloseHandleRes < BinData::Record
      endian :little
      request :request
      string :samHandle, :length => 20
      uint32 :windowsError
    end

    def closeDomain()
      if !@domainHandle.nil?
        samrCloseHandleReq = SamrCloseHandleReq.new(handle:@domainHandle)
        samrCloseHandleRes = @file.ioctl_send_recv(samrCloseHandleReq).buffer
        samrCloseHandleRes.raise_not_error_success("closeDomain")
        samrCloseHandleRes = SamrCloseHandleRes.read(samrCloseHandleRes)
        @domainHandle = nil
      end
    end

    def closeServer()
      if !@serverHandle.nil?
        samrCloseHandleReq = SamrCloseHandleReq.new(handle:@serverHandle)
        samrCloseHandleRes = @file.ioctl_send_recv(samrCloseHandleReq).buffer
        samrCloseHandleRes.raise_not_error_success("closeServer")
        samrCloseHandleRes = SamrCloseHandleRes.read(samrCloseHandleRes)
        @serverHandle = nil
      end
    end

    def close()
      closeDomain()
      closeServer()
      super
    end
end
end
