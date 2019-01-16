module SmbRpc
  class Svcctl < Rpc

    class OpenScmReq < BinData::Record
      endian :little
      request :request
      uint32 :ref_id_machine_name, :value => 1
      conformantandVaryingStrings :machine_name
      uint32 :databaseName
      uint32 :desiredAccess

      def initialize_instance
        super
        machine_name.str = "\\\\#{get_parameter(:serverName)}\x00".bytes.pack("v*")
        desiredAccess.value = get_parameter(:accessMask)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 15        #ROpenSCManagerW
      end
    end

    class OpenScmRes < BinData::Record
      endian :little
      response :response
      string :scHandle, :length => 20
      uint32 :windowsError
    end

    def openScm(scAccessMask:)
      openScmReq = OpenScmReq.new(serverName:@ip, accessMask:scAccessMask)
      openScmRes = @file.ioctl_send_recv(openScmReq).buffer
      openScmRes.raise_not_error_success("openScm")
      openScmRes = OpenScmRes.read(openScmRes)
      @scHandle = openScmRes.scHandle
      return self
    end
end
end
