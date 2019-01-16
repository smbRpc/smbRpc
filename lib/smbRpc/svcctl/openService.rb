module SmbRpc
  class Svcctl < Rpc
    class OpenServiceReq < BinData::Record
      endian :little
      request :request
      string :scHandle, :length => 20
      conformantandVaryingStrings :serviceName
      uint32 :desiredAccess

      def initialize_instance
        super
        scHandle.value = get_parameter(:handle)
        serviceName.str = "#{get_parameter(:svcName)}\x00".bytes.pack("v*")
        desiredAccess.value = get_parameter(:access)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 16        #ROpenServiceW
      end
    end

    class OpenServiceRes < BinData::Record
      endian :little
      request :request
      string :serviceHandle, :length => 20
      uint32 :windowsError
    end

    def openService(serviceName:, serviceAccessMask:)
      openServiceReq = OpenServiceReq.new(svcName:serviceName, handle:@scHandle, access:serviceAccessMask)
      openServiceRes = @file.ioctl_send_recv(openServiceReq).buffer
      openServiceRes.raise_not_error_success("openService")
      openServiceRes = OpenServiceRes.read(openServiceRes)
      @serviceHandle = openServiceRes.serviceHandle
      return self
    end
end
end
