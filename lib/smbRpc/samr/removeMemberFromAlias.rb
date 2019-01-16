module SmbRpc
  class Samr < Rpc

    class SamrRemoveMemberFromAliasReq < BinData::Record
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
        request.opnum.value = 32        #SamrRemoveMemberFromAlias
      end
    end

    class SamrRemoveMemberFromAliasRes < BinData::Record
      endian :little
      response :response
      uint32 :windowsError
    end

    def removeMemberFromAlias(memberId:)
      samrRemoveMemberFromAliasReq = SamrRemoveMemberFromAliasReq.new(handle:@aliasHandle, sid:memberId)
      samrRemoveMemberFromAliasRes = @file.ioctl_send_recv(samrRemoveMemberFromAliasReq).buffer
      samrRemoveMemberFromAliasRes.raise_not_error_success("removeMemberFromAlias")
      return self
    end

end
end

