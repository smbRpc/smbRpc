module SmbRpc
  class Svcctl < Rpc

    class DeleteServiceReq < BinData::Record
      endian :little
      request :request
      string :serviceHandle, :length => 20

      def initialize_instance
        super
        serviceHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 2        #RDeleteService
      end
    end

    class DeleteServiceRes < BinData::Record
      endian :little
      request :response
      uint32 :windowsError
    end

    def deleteService()
      deleteServiceReq = DeleteServiceReq.new(handle:@serviceHandle)
      deleteServiceRes = @file.ioctl_send_recv(deleteServiceReq).buffer
      deleteServiceRes.raise_not_error_success("deleteService")
      return 0
    end

end
end
