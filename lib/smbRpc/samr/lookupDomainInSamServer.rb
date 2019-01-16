module SmbRpc
  class Samr < Rpc

    class SamrLookupDomainInSamServerReq < BinData::Record
      endian :little
      request :request
      string :serverHandle, :length => 20
      rpc_unicode_string :name
      conformantandVaryingStrings :nameNdr

      def initialize_instance
        super
        serverHandle.value = get_parameter(:handle)
        domainNameUni = "#{get_parameter(:domainName)}\x00".bytes.pack("v*")
        name.len.value = domainNameUni.bytesize
        name.maximumLength.value = domainNameUni.bytesize
        nameNdr.str = domainNameUni
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 5        #SamrLookupDomainInSamServer
      end
    end

    class SamrLookupDomainInSamServerRes < BinData::Record
      endian :little
      request :request
      uint32 :ref_id_domainId
      sid_element :domainId, :onlyif => lambda { ref_id_domainId != 0 } #declared in lsarpc/lsaEnumerateAccounts.rb
      uint32 :windowsError
    end

    def lookupDomainInSamServer(domainName:)
      samrLookupDomainInSamServerReq = SamrLookupDomainInSamServerReq.new(handle:@serverHandle, domainName:domainName)
      samrLookupDomainInSamServerRes = @file.ioctl_send_recv(samrLookupDomainInSamServerReq).buffer
      samrLookupDomainInSamServerRes.raise_not_error_success("lookupDomainInSamServer")
      samrLookupDomainInSamServerRes = SamrLookupDomainInSamServerRes.read(samrLookupDomainInSamServerRes)
      return samrLookupDomainInSamServerRes.domainId.sid.to_s
    end

end
end

