module SmbRpc
  class Samr < Rpc

    class SamrRemoveMemberFromGroupReq < BinData::Record
      endian :little
      request :request
      string :groupHandle, :length => 20
      uint32 :memberId			#what happen to consistency MS?(removeMemberFromAlias)

      def initialize_instance
        super
        groupHandle.value = get_parameter(:handle)
        memberId.value = get_parameter(:rid)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 24        #SamrRemoveMemberFromGroup
      end
    end

    class SamrRemoveMemberFromGroupRes < BinData::Record
      endian :little
      response :response
      uint32 :windowsError
    end

    def removeMemberFromGroup(memberId:)
      samrRemoveMemberFromGroupReq = SamrRemoveMemberFromGroupReq.new(handle:@groupHandle, rid:memberId)
      samrRemoveMemberFromGroupRes = @file.ioctl_send_recv(samrRemoveMemberFromGroupReq).buffer
      samrRemoveMemberFromGroupRes.raise_not_error_success("removeMemberFromGroup")
      return self
    end

end
end

