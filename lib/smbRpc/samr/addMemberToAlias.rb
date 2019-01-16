module SmbRpc
  class Samr < Rpc

    class SamrAddMemberToAliasReq < BinData::Record
      endian :little
      request :request
      string :aliasHandle, :length => 20
      sid_element :memberId

      def initialize_instance
        super
        aliasHandle.value = get_parameter(:handle)
        sid = get_parameter(:sid)
        sidArray = sid.split("-")
        subAuthorityCount = sidArray.size - 3
        memberId.sub_auth.value = subAuthorityCount
        memberId.sid.revision.value = sidArray[1].to_i
        memberId.sid.subAuthorityCount.value = subAuthorityCount
        memberId.sid.identifierAuthority.value = [sidArray[2].to_i].pack("N").rjust(6, "\x00")
        subAuthorityCount.times do |i|
          memberId.sid.subAuthority[i] = sidArray[i + 3].to_i
        end
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 31        #SamrAddMemberToAlias
      end
    end

    class SamrAddMemberToAliasRes < BinData::Record
      endian :little
      response :response
      uint32 :windowsError
    end

    def addMemberToAlias(memberId:)
      samrAddMemberToAliasReq = SamrAddMemberToAliasReq.new(handle:@aliasHandle, sid:memberId)
      samrAddMemberToAliasRes = @file.ioctl_send_recv(samrAddMemberToAliasReq).buffer
      samrAddMemberToAliasRes.raise_not_error_success("addMemberToAlias")
      return self
    end

end
end

