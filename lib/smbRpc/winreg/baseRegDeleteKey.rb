module SmbRpc
  class Winreg < Rpc

    class BaseRegDeleteKeyReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpSubKey
      conformantandVaryingStrings :lpSubKeyNdr

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        uniString = "#{get_parameter(:subKey)}\x00".bytes.pack("v*")
        lpSubKey.len.value = uniString.bytesize
        lpSubKey.maximumLength.value = uniString.bytesize
        lpSubKeyNdr.str.value = uniString
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 7        #BaseRegDeleteKey
      end
    end

    class BaseRegDeleteKeyRes < BinData::Record
      endian :little
      request :request
      uint32 :windowsError
    end

    def baseRegDeleteKey(subKey:)
      baseRegDeleteKeyReq = BaseRegDeleteKeyReq.new(handle:@subKeyHandle, subKey:subKey)
      baseRegDeleteKeyRes = @file.ioctl_send_recv(baseRegDeleteKeyReq).buffer
      baseRegDeleteKeyRes.raise_not_error_success("baseRegDeleteKey")
      return self
    end

end
end

