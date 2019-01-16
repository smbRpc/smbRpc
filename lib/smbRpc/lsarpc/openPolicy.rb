
module SmbRpc
  class Lsarpc < Rpc

    attr_accessor :policyHandle

    class Lsapr_object_attributes < BinData::Record
      endian :little
      uint32 :len
      uint32 :rootDirectory
      uint32 :objectName
      uint32 :attributes
      uint32 :securityDescriptor
      uint32 :securityQualityOfService
      def initialize_instance
        super
        len.value = self.num_bytes
      end
    end

    class LsarOpenPolicy2Req < BinData::Record
      endian :little
      request :request
      uint32 :systemName
      lsapr_object_attributes :objectAttributes
      uint32 :desiredAccess
      def initialize_instance
        super
        desiredAccess.value = get_parameter(:accessMask)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 44        #LsarOpenPolicy2
      end
    end

    class LsarOpenPolicy2Res < BinData::Record
      endian :little
      response :response
      string :policyHandle, :length => 20
      uint32 :windowsError
    end

    def openPolicy(desiredAccess:LSARPC_ALL_ACCESS_MASK["MAXIMUM_ALLOWED"])
      lsarOpenPolicy2Req = LsarOpenPolicy2Req.new(accessMask:desiredAccess)
      lsarOpenPolicy2Res = @file.ioctl_send_recv(lsarOpenPolicy2Req).buffer
      lsarOpenPolicy2Res.raise_not_error_success("openPolicy")
      lsarOpenPolicy2Res = LsarOpenPolicy2Res.read(lsarOpenPolicy2Res)
      @policyHandle = lsarOpenPolicy2Res.policyHandle
      return self
    end

end
end
