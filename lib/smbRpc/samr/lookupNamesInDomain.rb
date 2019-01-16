module SmbRpc
  class Samr < Rpc

    class SamrLookupNamesInDomainReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      uint32 :numberOfName, :value => 1
      uint32 :maxCount, :value => 1000	#range max at 1000
      uint32 :offset
      uint32 :actualCont, :value => 1
      rpc_unicode_string :name 		#declared in lsarpc/lsaQueryInformationPolicy.rb
      conformantandVaryingStrings :nameNdr

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)

        nameNdr.str = get_parameter(:accName).bytes.pack("v*")
        numBytes = nameNdr.actual_count * 2
        name.len.value = numBytes
        name.maximumLength.value = numBytes
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 17        #SamrLookupNamesInDomain
      end
    end

    class SamrLookupNamesInDomainRes < BinData::Record
      endian :little
      request :request
      uint32 :numberOfRef_id_relativeId
      uint32 :ref_id_relativeId
      uint32 :numberOfRelativeId
      uint32 :relativeId
      uint32 :numberOfRef_id_use
      uint32 :ref_id_use
      uint32 :numberOfuse
      uint32 :use
      uint32 :windowsError
    end

    def lookupNamesInDomain(name:)
      samrLookupNamesInDomainReq = SamrLookupNamesInDomainReq.new(accName:name, handle:@domainHandle)
      samrLookupNamesInDomainRes = @file.ioctl_send_recv(samrLookupNamesInDomainReq).buffer
      samrLookupNamesInDomainRes.raise_not_error_success("lookupNamesInDomain")
      samrLookupNamesInDomainRes = SamrLookupNamesInDomainRes.read(samrLookupNamesInDomainRes)
      return {
        :relativeId => samrLookupNamesInDomainRes.relativeId.to_i, 
        :type => samrLookupNamesInDomainRes.use.to_i
      }
      end

end
end

