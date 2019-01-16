module SmbRpc
  class Samr < Rpc

    class SamrGetMembersInAliasReq < BinData::Record
      endian :little
      request :request
      string :aliasHandle, :length => 20

      def initialize_instance
        super
        aliasHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 33        #SamrGetMembersInAlias
      end
    end

    class SamrGetMembersInAliasRes < BinData::Record
      endian :little
      response :response
      uint32 :numberOfSids
      uint32 :ref_id_members

      uint32 :numberOfMembers, :onlyif => lambda { numberOfSids.value > 0 }
      array :ref_id_member, :type => :uint32, :initial_length => :numberOfMembers, :onlyif => lambda { numberOfSids.value > 0 }
      array :member, :type => :sid_element, :initial_length => :numberOfMembers, :onlyif => lambda { numberOfSids.value > 0 }
      uint32 :windowsError
    end

    def getMembersInAlias
      samrGetMembersInAliasReq = SamrGetMembersInAliasReq.new(handle:@aliasHandle)
      samrGetMembersInAliasRes = @file.ioctl_send_recv(samrGetMembersInAliasReq).buffer
      samrGetMembersInAliasRes.raise_not_error_success("getMembersInAlias")
      samrGetMembersInAliasRes = SamrGetMembersInAliasRes.read(samrGetMembersInAliasRes)
      out = []
      samrGetMembersInAliasRes.member.each{|e| out << e.sid.to_s}
      return out
    end

end
end

