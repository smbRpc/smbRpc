module SmbRpc
  class Samr < Rpc

    class SamrEnumerateAliasesInDomainReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      uint32 :enumerationContext
      uint32 :preferedMaximumLength, :value => 1024

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        enumerationContext.value = get_parameter(:enumContext)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 15        #SamrEnumerateAliasesInDomain  
      end
    end

    class SamrEnumerateAliasesInDomainRes  < BinData::Record
      endian :little
      request :request
      uint32 :enumerationContext

      uint32 :ref_id_buffer
      uint32 :numberOfBuffer
      uint32 :ref_id_sampr_enumeration_buffer
      uint32 :entriesRead
      #_SAMPR_RID_ENUMERATION declared in enumerateUsersInDomain.rb
      array :name, :type => :sampr_rid_enumeration, :initial_length => :entriesRead
      array :nameNdr, :type => :conformantandVaryingStrings, :initial_length => :entriesRead

      uint32 :countReturned, :onlyif => lambda { entriesRead.value > 0 }
      uint32 :windowsError
    end

    def enumerateAliasesInDomain
      result = 0
      enumerationContext = 0
      out = []
      loop do
        samrEnumerateAliasesInDomainReq = SamrEnumerateAliasesInDomainReq.new(handle:@domainHandle, enumContext:enumerationContext)
        samrEnumerateAliasesInDomainRes = @file.ioctl_send_recv(samrEnumerateAliasesInDomainReq).buffer
        samrEnumerateAliasesInDomainRes = SamrEnumerateAliasesInDomainRes.read(samrEnumerateAliasesInDomainRes)
        enumerationContext = samrEnumerateAliasesInDomainRes.enumerationContext
        samrEnumerateAliasesInDomainRes.numberOfBuffer.times do |i|
          h = {}
          h[:rid] = samrEnumerateAliasesInDomainRes.name[i].relativeId
          h[:aliasName] = samrEnumerateAliasesInDomainRes.nameNdr[i].str.unpack("v*").pack("c*")
          out << h
        end
        result = samrEnumerateAliasesInDomainRes.windowsError
        break if result != WindowsError::NTStatus::STATUS_MORE_ENTRIES #0x00000105
      end
      result == 0? result : (raise "enumerateAliasesInDomain Fail, WinError: %i"%[result])
      return out
    end

end
end

