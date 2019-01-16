module SmbRpc
  class Samr < Rpc

    class SamrEnumerateDomainsInSamServerReq < BinData::Record
      endian :little
      request :request
      string :serverHandle, :length => 20
      uint32 :enumerationContext
      uint32 :preferedMaximumLength, :value => 512

      def initialize_instance
        super
        serverHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 6        #SamrEnumerateDomainsInSamServer
      end
    end

    class SamrEnumerateDomainsInSamServerRes < BinData::Record
      endian :little
      request :request
      uint32 :enumerationContext
      uint32 :ref_id_buffer
      uint32 :numberOfBuffer
      uint32 :ref_id_sampr_enumeration_buffer
      uint32 :entriesRead
      #sampr_rid_enumeration declared in samEnumerateUsersInDomain.rb
      array :name, :type => :sampr_rid_enumeration, :initial_length => :entriesRead
      array :nameNdr, :type => :conformantandVaryingStrings, :initial_length => :entriesRead

      uint32 :countReturned
      uint32 :windowsError
    end

    def enumerateDomainsInSamServer()
      samrEnumerateDomainsInSamServerReq = SamrEnumerateDomainsInSamServerReq.new(handle:@serverHandle)
      samrEnumerateDomainsInSamServerRes = @file.ioctl_send_recv(samrEnumerateDomainsInSamServerReq).buffer
      samrEnumerateDomainsInSamServerRes.raise_not_error_success("enumerateDomainsInSamServer")
      samrEnumerateDomainsInSamServerRes = SamrEnumerateDomainsInSamServerRes.read(samrEnumerateDomainsInSamServerRes)
      out = []
      samrEnumerateDomainsInSamServerRes.countReturned.times do |i|
        h = {}
        h[:rid] = samrEnumerateDomainsInSamServerRes.name[i].relativeId
        h[:domainName] = samrEnumerateDomainsInSamServerRes.nameNdr[i].str.unpack("v*").pack("c*")
        out << h
      end
      return out
    end

end
end

