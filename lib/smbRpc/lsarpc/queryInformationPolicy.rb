

module SmbRpc
  class Lsarpc < Rpc

    #[MS-DTYPE]
    class Rpc_unicode_string < BinData::Record
      endian :little
      uint16 :len					#length in bytes, multiple of 2, not include null terminate
      uint16 :maximumLength				#maxlength in bytes, multiple of 2, not less than length 
							#If MaximumLength is greater than zero, the buffer MUST contain a non-null value
      uint32 :ref_id_buffer, :initial_value => 1	#set null pointer if maximumLength == 0		
    end

    class Rpc_sid < BinData::Record
      endian :little
      uint8 :revision
      uint8 :subAuthorityCount
      string :identifierAuthority, :length => 6 
      array :subAuthority, :type => :uint32, :initial_length => :subAuthorityCount

      def to_s
        sid = "S-%i"%[self.revision]
        sid << "-%i"%[self.identifierAuthority.unpack("H*")[0].to_i(16)]
        self.subAuthority.each { |i| sid << "-%i"%[i] }
        return sid
      end
    end

    class Lsapr_policy_dns_domain_info < BinData::Record
      endian :little
      rpc_unicode_string :name
      rpc_unicode_string :dnsDomainName
      rpc_unicode_string :dnsForestName
      string :guid, :length => 16
      uint32 :sid
      conformantandVaryingStrings :nameNdr, :onlyif => lambda { name.maximumLength > 0 } 
      conformantandVaryingStrings :dnsDomainNameNdr, :onlyif => lambda { dnsDomainName.maximumLength > 0 } 
      conformantandVaryingStrings :dnsForestNameNdr, :onlyif => lambda { dnsForestName.maximumLength > 0 }
    end

    class LsarQueryInformationPolicy2Req < BinData::Record
      endian :little
      request :request
      string :policyHandle, :length => 20
      uint16 :informationClass

      def initialize_instance
        super
        policyHandle.value = get_parameter(:handle)
        informationClass.value = get_parameter(:infoClass)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 46        		#LsarQueryInformationPolicy2
      end
    end

    class LsarQueryInformationPolicy2Res < BinData::Record
      endian :little
      response :response
      uint32 :ref_id_policyInformation
      uint32 :informationClass_tag

      choice :policyInformation, :selection => lambda { get_parameter(:infoClass) } do
        uint32 6					#enum _POLICY_LSA_SERVER_ROLE { PolicyServerRoleBackup = 2, PolicyServerRolePrimary}
        lsapr_policy_dns_domain_info 12
      end
      uint32 :windowsError
    end

    def queryInformationPolicy(informationClass:LSARPC_POLICY_INFORMATION_CLASS["PolicyDnsDomainInformation"])
      lsarQueryInformationPolicy2Req = LsarQueryInformationPolicy2Req.new(handle:@policyHandle, infoClass:informationClass)
      response = @file.ioctl_send_recv(lsarQueryInformationPolicy2Req).buffer
      response.raise_not_error_success("queryInformationPolicy")
      lsarQueryInformationPolicy2Res = LsarQueryInformationPolicy2Res.new(infoClass:informationClass)
      lsarQueryInformationPolicy2Res.read(response)
      short = lsarQueryInformationPolicy2Res.policyInformation
      out = {}
      if informationClass == LSARPC_POLICY_INFORMATION_CLASS["PolicyDnsDomainInformation"]
        out[:name] = short.nameNdr.str.unpack("v*").pack("c*") if short.name.len > 0
        out[:dnsDomainName] = short.dnsDomainNameNdr.str.unpack("v*").pack("c*") if short.dnsDomainName.len > 0
        out[:dnsForestName] = short.dnsForestNameNdr.str.unpack("v*").pack("c*") if short.dnsForestName.len > 0
        out[:guid] = short.guid
        out[:sid] = short.sid
      end
      if informationClass == LSARPC_POLICY_INFORMATION_CLASS["PolicyLsaServerRoleInformation"]
        out[:policyServerRole] = short
      end
      return out
    end

end
end
