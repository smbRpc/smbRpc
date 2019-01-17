module SmbRpc
  class Samr < Rpc

    class SamrEnumerateUsersInDomainReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      uint32 :enumerationContext
      uint32 :userAccountControl
      uint32 :preferedMaximumLength, :value => 1024

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        enumerationContext.value = get_parameter(:enumContext)
        userAccountControl.value = get_parameter(:accountControl)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 13        #SamrEnumerateUsersInDomain
      end
    end

    class Sampr_rid_enumeration < BinData::Record
      endian :little
      uint32 :relativeId
      rpc_unicode_string :name
    end

    class SamrEnumerateUsersInDomainRes < BinData::Record
      endian :little
      request :request
      uint32 :enumerationContext
      uint32 :ref_id_buffer
      uint32 :numberOfBuffer
      uint32 :ref_id_sampr_enumeration_buffer
      uint32 :entriesRead
      #_SAMPR_RID_ENUMERATION
      array :name, :type => :sampr_rid_enumeration, :initial_length => :entriesRead
      array :nameNdr, :type => :conformantandVaryingStrings, :initial_length => :entriesRead
      uint32 :countReturned, :onlyif => lambda { entriesRead.value > 0 }
      uint32 :windowsError
    end

    def enumerateUsersInDomain(userAccountControl:SAMR_USER_ACCOUNT["USER_NORMAL_ACCOUNT"])
      result = 0
      enumerationContext = 0
      out = []
      loop do
        samrEnumerateUsersInDomainReq = SamrEnumerateUsersInDomainReq.new(handle:@domainHandle, accountControl:userAccountControl, enumContext:enumerationContext)
        samrEnumerateUsersInDomainRes = @file.ioctl_send_recv(samrEnumerateUsersInDomainReq).buffer
        samrEnumerateUsersInDomainRes = SamrEnumerateUsersInDomainRes.read(samrEnumerateUsersInDomainRes)
        enumerationContext = samrEnumerateUsersInDomainRes.enumerationContext
        samrEnumerateUsersInDomainRes.numberOfBuffer.times do |i|
          h = {}
          h[:rid] = samrEnumerateUsersInDomainRes.name[i].relativeId.to_i
          h[:userName] = samrEnumerateUsersInDomainRes.nameNdr[i].str.unpack("v*").pack("c*")
          out << h
        end
        result = samrEnumerateUsersInDomainRes.windowsError
        break if result != WindowsError::NTStatus::STATUS_MORE_ENTRIES #0x00000105
      end
      result == 0? result : (raise "SamEnumerateUsersInDomain Fail, WinError: %i"%[result])
      return out
    end

end
end

