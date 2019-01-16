module SmbRpc
  class Samr < Rpc

    class SamrDeleteGroupReq < BinData::Record
      endian :little
      request :request
      string :groupHandle, :length => 20

      def initialize_instance
        super
        groupHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 23        #SamrDeleteGroup
      end
    end

    class SamrDeleteGroupRes < BinData::Record
      endian :little
      request :request
      string :groupHandle, :length => 20
      uint32 :windowsError
    end

    def deleteGroup
      samrDeleteGroupReq = SamrDeleteGroupReq.new(handle:@groupHandle)
      samrDeleteGroupRes = @file.ioctl_send_recv(samrDeleteGroupReq).buffer
      samrDeleteGroupRes.raise_not_error_success("deleteGroup")
      samrDeleteGroupRes = SamrDeleteGroupRes.read(samrDeleteGroupRes)
      @groupHandle = nil
      return 0
    end

end
end

