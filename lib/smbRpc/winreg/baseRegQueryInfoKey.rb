module SmbRpc
  class Winreg < Rpc

    class BaseRegQueryInfoKeyReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpClassIn

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        lpClassIn.len.value = 0
        lpClassIn.maximumLength.value = 0x1000
        lpClassIn.ref_id_buffer.value = 0
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 16        #BaseRegQueryInfoKey
      end
    end

    class BaseRegQueryInfoKeyRes < BinData::Record
      endian :little
      request :request
      rpc_unicode_string :lpClassOut
      conformantandVaryingStrings :lpClassOutNdr
      uint32 :lpcSubKeys
      uint32 :lpcbMaxSubKeyLen
      uint32 :lpcbMaxClassLen
      uint32 :lpcValues
      uint32 :lpcbMaxValueNameLen
      uint32 :lpcbMaxValueLen
      uint32 :lpcbSecurityDescriptor
      uint64 :lpftLastWriteTime
      uint32 :windowsError
    end

    def baseRegQueryInfoKey
      baseRegQueryInfoKeyReq = BaseRegQueryInfoKeyReq.new(handle:(@subKeyHandle || @rootKeyHandle))
      baseRegQueryInfoKeyRes = @file.ioctl_send_recv(baseRegQueryInfoKeyReq).buffer
      baseRegQueryInfoKeyRes.raise_not_error_success("baseRegQueryInfoKey")
      baseRegQueryInfoKeyRes = BaseRegQueryInfoKeyRes.read(baseRegQueryInfoKeyRes)
      k = baseRegQueryInfoKeyRes
      return { :numberOfSubkeys => k.lpcSubKeys,
               :maxSubkeySize => k.lpcbMaxSubKeyLen,
               :maxClassSize => k.lpcbMaxClassLen,
               :numberOfValues => k.lpcValues,
               :maxValueNameSize => k.lpcbMaxValueNameLen,
               :maxValueSize => k.lpcbMaxValueLen,
               :securityDescriptorSize => k.lpcbSecurityDescriptor,
               :lastWriteTime => k.lpftLastWriteTime
      }
    end

end
end

