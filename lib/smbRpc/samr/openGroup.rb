module SmbRpc
  class Samr < Rpc

    class SamrOpenGroupReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      uint32 :desiredAccess
      uint32 :groupId

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        desiredAccess.value = get_parameter(:access)
        groupId.value = get_parameter(:gid)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 19        #SamrOpenGroup
      end
    end

    class SamrOpenGroupRes < BinData::Record
      endian :little
      request :request
      string :groupHandle, :length => 20
      uint32 :windowsError
    end

    def openGroup(groupId:, desiredAccess:SAMR_COMMON_ACCESS_MASK["MAXIMUM_ALLOWED"])
      samrOpenGroupReq = SamrOpenGroupReq.new(gid:groupId, access:desiredAccess, handle:@domainHandle)
      samrOpenGroupRes = @file.ioctl_send_recv(samrOpenGroupReq).buffer
      samrOpenGroupRes.raise_not_error_success("openGroup")
      samrOpenGroupRes = SamrOpenGroupRes.read(samrOpenGroupRes)
      @groupHandle = samrOpenGroupRes.groupHandle
      return self
    end

end
end

