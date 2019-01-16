module SmbRpc
  class Samr < Rpc

    class SamrDeleteUserReq < BinData::Record
      endian :little
      request :request
      string :userHandle, :length => 20

      def initialize_instance
        super
        userHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 35        #SamrDeleteUser
      end
    end

    class SamrDeleteUserRes < BinData::Record
      endian :little
      request :request
      string :userHandle, :length => 20
      uint32 :windowsError
    end

    def deleteUser
      samrDeleteUserReq = SamrDeleteUserReq.new(handle:@userHandle)
      samrDeleteUserRes = @file.ioctl_send_recv(samrDeleteUserReq).buffer
      samrDeleteUserRes.raise_not_error_success("deleteUser")
      samrDeleteUserRes = SamrDeleteUserRes.read(samrDeleteUserRes)
      @userHandle = samrDeleteUserRes.userHandle
      return 0
    end

end
end

