module SmbRpc
  class Winreg < Rpc

    class BaseRegEnumKeyReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20

      uint32 :dwIndex
      rpc_unicode_string :lpNameIn
      uint32 :ref_id_lpClassIn, :value => 1
      rpc_unicode_string :lpClassIn
      uint32 :lpftLastWriteTime

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        dwIndex.value = get_parameter(:index)
        lpNameIn.len.value = 0
        lpNameIn.maximumLength.value = 0x1000
        lpNameIn.ref_id_buffer.value = 0
        lpClassIn.len.value = 0
        lpClassIn.maximumLength.value = 0x1000
        lpClassIn.ref_id_buffer.value = 0
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 9        #BaseRegEnumKey
      end
    end

    class BaseRegEnumKeyRes < BinData::Record
      endian :little
      request :request

      rpc_unicode_string :lpNameOut
      conformantandVaryingStrings :lpNameOutNdr
      rpc_unicode_string :lplpClassOut
      uint32 :lpftLastWriteTime

      uint32 :windowsError
    end

    def baseRegEnumKey(index:)
      baseRegEnumKeyReq = BaseRegEnumKeyReq.new(handle:(@subKeyHandle || @rootKeyHandle), index:index)
      baseRegEnumKeyRes = @file.ioctl_send_recv(baseRegEnumKeyReq).buffer
      baseRegEnumKeyRes.raise_not_error_success("baseRegEnumKey")
      baseRegEnumKeyRes = BaseRegEnumKeyRes.read(baseRegEnumKeyRes)
      out = baseRegEnumKeyRes.lpNameOutNdr.str.unpack("v*").pack("c*")
      return out.chop if out[-1] == "\x00"
    end

end
end

