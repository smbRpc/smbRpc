module SmbRpc
  class Samr < Rpc

    class SamrGetMembersInGroupReq < BinData::Record
      endian :little
      request :request
      string :groupHandle, :length => 20

      def initialize_instance
        super
        groupHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 25        #SamrGetMembersInGroup
      end
    end

    class SamrGetMembersInGroupRes < BinData::Record
      endian :little
      response :response
      uint32 :ref_id_members
      uint32 :numberOfMembers
      uint32 :ref_id_relativeId
      uint32 :ref_id_attributes
      uint32 :numberOfRelativeId, :onlyif => lambda { ref_id_relativeId.value > 0 }
      array :relativeId, :type => :uint32, :initial_length => :numberOfMembers
      uint32 :numberOfAttributes, :onlyif => lambda { ref_id_attributes.value > 0 }
      array :attributes, :type => :uint32, :initial_length => :numberOfMembers
      uint32 :windowsError
    end

    def getMembersInGroup
      samrGetMembersInGroupReq = SamrGetMembersInGroupReq.new(handle:@groupHandle)
      samrGetMembersInGroupRes = @file.ioctl_send_recv(samrGetMembersInGroupReq).buffer
      samrGetMembersInGroupRes.raise_not_error_success("getMembersInGroup")
      samrGetMembersInGroupRes = SamrGetMembersInGroupRes.read(samrGetMembersInGroupRes)
      out = []
      samrGetMembersInGroupRes.numberOfMembers.times do |i|
        out << {:relativeId => samrGetMembersInGroupRes.relativeId[i], :attributes => samrGetMembersInGroupRes.attributes[i]}     
      end
      return out
    end

end
end

