module SmbRpc
  class Lsarpc < Rpc

    class LsarLookupSidsReq < BinData::Record
      endian :little
      request :request
      string :policyHandle, :length => 20
      lsapr_account_enum_buffer :sidEnumBuffer		#declare in lsaEnumerateAccounts.rb
      uint32 :entriesRead
      uint32 :translatedNames
      uint32 :lookupLevel, :value => 1
      uint32 :mappedCount

      def initialize_instance
        super
        policyHandle.value = get_parameter(:handle)

        sid = get_parameter(:sid)
        sidEnumBuffer.entriesRead.value = 1

        sidArray = sid.split("-")
        subAuthorityCount = sidArray.size - 3
        sidEnumBuffer.ref_id_information[0].value = 1
        sidEnumBuffer.information[0].sub_auth.value = subAuthorityCount
        sidEnumBuffer.information[0].sid.revision.value = sidArray[1].to_i
        sidEnumBuffer.information[0].sid.subAuthorityCount.value = subAuthorityCount
        sidEnumBuffer.information[0].sid.identifierAuthority.value = [sidArray[2].to_i].pack("N").rjust(6, "\x00")
        subAuthorityCount.times do |i|
          sidEnumBuffer.information[0].sid.subAuthority[i] = sidArray[i + 3].to_i
        end
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 15        		#LsarLookupSids
      end
    end

    class Lsapr_trust_information < BinData::Record
      endian :little
      uint16 :len
      uint16 :maxLength
      uint32 :ref_id_name
      uint32 :ref_id_sid
      conformantandVaryingStrings :name
      sid_element :sid					#declared in lsarpc/lsaEnumerateAccounts.rb
    end

    class Lsapr_referenced_domain_list < BinData::Record
      endian :little
      uint32 :numberOfEntries
      uint32 :ref_id_domains
      uint32 :maxEntries
    end

    class Lsapr_translated_name < BinData::Record
      endian :little
      uint32 :use
      rpc_unicode_string :name
      uint32 :domainIndex
    end

    class Lsapr_translated_names < BinData::Record
      endian :little
      uint32 :numberOfNames
      uint32 :ref_id_names
      uint32 :numberOfEntries, :value => :numberOfNames
      array :names, :type => :lsapr_translated_name, :initial_length => :numberOfEntries
      array :nameNdr, :type => :conformantandVaryingStrings, :initial_length => :numberOfEntries
    end

    class LsarLookupSidsRes < BinData::Record
      endian :little
      response :response
      uint32 :ref_id_referencedDomains
      lsapr_referenced_domain_list :referencedDomains
      uint32 :numberOfEntries
      lsapr_trust_information :domain
      lsapr_translated_names :translatedNames
      uint32 :mappedCount
      uint32 :windowsError
    end

    def lookupSids(sid:)
      lsarLookupSidsReq = LsarLookupSidsReq.new(handle:@policyHandle, sid:sid)
      lsarLookupSidsRes = @file.ioctl_send_recv(lsarLookupSidsReq).buffer
      lsarLookupSidsRes.raise_not_error_success("lookupSids")
      lsarLookupSidsRes = LsarLookupSidsRes.read(lsarLookupSidsRes)
      result = lsarLookupSidsRes.windowsError
      result == 0? result : (raise "LsaLookupSids Fail, WinError: %i"%[result])
      h = {}
      h[:domain] = lsarLookupSidsRes.domain.name.str.unpack("v*").pack("c*")
      h[:name] = lsarLookupSidsRes.translatedNames.nameNdr[0].str.unpack("v*").pack("c*")
      h[:type] = lsarLookupSidsRes.translatedNames.names[0].use
      return h
    end

end
end
