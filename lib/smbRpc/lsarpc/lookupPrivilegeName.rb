module SmbRpc
  class Lsarpc < Rpc

    class LsarLookupPrivilegeNameReq < BinData::Record
      endian :little
      request :request
      string :policyHandle, :length => 20
      string :luid, :length => 8

      def initialize_instance
        super
        policyHandle.value = get_parameter(:handle)
        luid.value = get_parameter(:lu)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 32        #LsarLookupPrivilegeName
      end
    end

    class LsarLookupPrivilegeNameRes < BinData::Record
      endian :little
      response :response
      uint32 :ref_id_name
      rpc_unicode_string :name
      conformantandVaryingStrings :nameNdr
      uint32 :windowsError
    end

    def lookupPrivilegeName(luid:)
      lsarLookupPrivilegeNameReq = LsarLookupPrivilegeNameReq.new(handle:@policyHandle, lu:luid)
      lsarLookupPrivilegeNameRes = @file.ioctl_send_recv(lsarLookupPrivilegeNameReq).buffer
      lsarLookupPrivilegeNameRes.raise_not_error_success("lookupPrivilegeName")
      lsarLookupPrivilegeNameRes = LsarLookupPrivilegeNameRes.read(lsarLookupPrivilegeNameRes)
      return lsarLookupPrivilegeNameRes.nameNdr.str.unpack("v*").pack("c*")
    end

end
end
