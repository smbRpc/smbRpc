module SmbRpc
  class Lsarpc < Rpc

    class Lsapr_translated_sids < BinData::Record
      endian :little
      uint32 :numberOfEntries
      choice :sids, :selection => :numberOfEntries do
        uint32 0     
        array :default, :type => :rpc_sid, :initial_length => :numberOfEntries 
      end
    end

    class LsarLookupNamesReq < BinData::Record
      endian :little
      request :request
      string :policyHandle, :length => 20
      uint32 :numCount, :value => 1
      uint32 :numberOfNames, :value => :numCount
      rpc_unicode_string :name
      conformantandVaryingStrings :nameNdr
      lsapr_translated_sids :translatedSids
      uint32 :lookupLevel, :value => 1
      uint32 :mappedCount

      def initialize_instance
        super
        policyHandle.value = get_parameter(:handle)
        uniString = get_parameter(:accountName).bytes.pack("v*")
        name.len.value = uniString.bytesize
        name.maximumLength.value = uniString.bytesize
        nameNdr.str.value = uniString

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 14        #LsarLookupNames
      end
    end

    class Lsa_translated_sid < BinData::Record
      endian :little
      uint32 :use
      uint32 :relativeId
      uint32 :domainIndex
    end

    class LsarLookupNamesRes < BinData::Record
      endian :little
      response :response
      uint32 :ref_id_referencedDomains
      lsapr_referenced_domain_list :referencedDomains	#already declared in lsarpc/lsaLookupSids.rb
      uint32 :numberOfEntries
      lsapr_trust_information :domain			#already declared in lsarpc/lsaLookupSids.rb
      uint32 :numberOfSids
      uint32 :ref_id_translatedSids
      uint32 :numberOfTranslatedSids
      lsa_translated_sid :translatedSids
      uint32 :mappedCount
      uint32 :windowsError
    end

    def lookupNames(name:)
      lsarLookupNamesReq = LsarLookupNamesReq.new(handle:@policyHandle, accountName:name)
      lsarLookupNamesRes = @file.ioctl_send_recv(lsarLookupNamesReq).buffer
      lsarLookupNamesRes.raise_not_error_success("lookupNames")
      lsarLookupNamesRes = LsarLookupNamesRes.read(lsarLookupNamesRes)
      h = {}
      h[:domain] = lsarLookupNamesRes.domain.name.str.unpack("v*").pack("c*")
      h[:sid] = lsarLookupNamesRes.domain.sid.sid.to_s
      h[:rid] = lsarLookupNamesRes.translatedSids.relativeId.to_i
      h[:type] = lsarLookupNamesRes.translatedSids.use.to_i
      return h
    end

end
end
