module SmbRpc
  class Samr < Rpc

    class SamrAddMemberToGroupReq < BinData::Record
      endian :little
      request :request
      string :groupHandle, :length => 20
      uint32 :memberId			#addMemberToAlias use SID, why not here MS?
      uint32 :attributes

      def initialize_instance
        super
        groupHandle.value = get_parameter(:handle)
        memberId.value = get_parameter(:rid)
        attributes.value = get_parameter(:attr)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 22        #SamrAddMemberToGroup
      end
    end

    class SamrAddMemberToGroupRes < BinData::Record
      endian :little
      response :response
      uint32 :windowsError
    end

    def addMemberToGroup(memberId:, attributes:SAMR_SE_GROUP_ATTRIBUTES["SE_GROUP_ENABLED_BY_DEFAULT"])
      samrAddMemberToGroupReq = SamrAddMemberToGroupReq.new(handle:@groupHandle, rid:memberId, attr:attributes)
      samrAddMemberToGroupRes = @file.ioctl_send_recv(samrAddMemberToGroupReq).buffer
      samrAddMemberToGroupRes.raise_not_error_success("addMemberToGroup")
      return self
    end

end
end

