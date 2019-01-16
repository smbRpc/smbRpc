module SmbRpc
  class Samr < Rpc

    class SamrCreateGroupInDomainReq < BinData::Record
      endian :little
      request :request
      string :domainHandle, :length => 20
      rpc_unicode_string :name 		#declared in lsarpc/lsaQueryInformationPolicy.rb
      conformantandVaryingStrings :nameNdr
      uint32 :desiredAccess

      def initialize_instance
        super
        domainHandle.value = get_parameter(:handle)
        nameNdr.str = get_parameter(:groupName).bytes.pack("v*")
        numBytes = nameNdr.actual_count * 2
        name.len.value = numBytes
        name.maximumLength.value = numBytes
        desiredAccess.value = get_parameter(:access)

        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 10        #SamrCreateGroupInDomain
      end
    end

    class SamrCreateGroupInDomainRes < BinData::Record
      endian :little
      request :request
      string :groupHandle, :length => 20
      uint32 :relativeId
      uint32 :windowsError
    end

    def createGroupInDomain(name:, desiredAccess:SAMR_GROUP_ACCESS_MASK["GROUP_ALL_ACCESS"])
      samrCreateGroupInDomainReq = SamrCreateGroupInDomainReq.new(groupName:name, access:desiredAccess, handle:@domainHandle)

      samrCreateGroupInDomainRes = @file.ioctl_send_recv(samrCreateGroupInDomainReq).buffer
      samrCreateGroupInDomainRes.raise_not_error_success("createGroupInDomainRes")
      samrCreateGroupInDomainRes = SamrCreateGroupInDomainRes.read(samrCreateGroupInDomainRes)
      @groupHandle = samrCreateGroupInDomainRes.groupHandle
      return self
      end

end
end

