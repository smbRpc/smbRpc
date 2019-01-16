module SmbRpc
  class Samr < Rpc

    class SamrLookupIdsInDomainReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20

      uint32 :numberOfName, :value => 1
      uint32 :maxCount, :value => 1000	#range max at 1000
      uint32 :offset
      uint32 :actualCont, :value => 1
      uint32 :relativeId

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        relativeId.value = get_parameter(:rid)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 18        #SamrLookupIdsInDomain
      end
    end

    class SamrLookupIdsInDomainRes < BinData::Record
      endian :little
      request :request
      uint32 :numberOfRef_id_name
      uint32 :ref_id_name
      uint32 :numberOfName
      rpc_unicode_string :name 		#declared in lsarpc/lsaQueryInformationPolicy.rb
      conformantandVaryingStrings :nameNdr
      uint32 :numberOfRef_id_use
      uint32 :ref_id_use
      uint32 :numberOfuse
      uint32 :use
      uint32 :windowsError
    end

    def lookupIdsInDomain(relativeId:)
      samrLookupIdsInDomainReq = SamrLookupIdsInDomainReq.new(rid:relativeId, handle:@domainHandle)
      samrLookupIdsInDomainRes = @file.ioctl_send_recv(samrLookupIdsInDomainReq).buffer
      samrLookupIdsInDomainRes.raise_not_error_success("lookupIdsInDomain")
      samrLookupIdsInDomainRes = SamrLookupIdsInDomainRes.read(samrLookupIdsInDomainRes)
      return {
        :name => samrLookupIdsInDomainRes.nameNdr.str.unpack("v*").pack("c*"), 
        :type => samrLookupIdsInDomainRes.use
      }
      end

end
end

