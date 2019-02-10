module SmbRpc
  class Winreg < Rpc

    class BaseRegDeleteValueReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpValueName
      conformantandVaryingStrings :lpValueNameNdr

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        uniString = "#{get_parameter(:valueName)}\x00".bytes.pack("v*")
        lpValueName.len.value = uniString.bytesize
        lpValueName.maximumLength.value = uniString.bytesize
        lpValueNameNdr.str.value = uniString
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 8        #BaseRegDeleteValue
      end
    end

    class BaseRegDeleteValueRes < BinData::Record
      endian :little
      request :request
      uint32 :windowsError
    end

    def baseRegDeleteValue(valueName:)
      baseRegDeleteValueReq = BaseRegDeleteValueReq.new(handle:(@subKeyHandle || @rootKeyHandle), valueName:valueName)
      baseRegDeleteValueRes = @file.ioctl_send_recv(baseRegDeleteValueReq).buffer
      baseRegDeleteValueRes.raise_not_error_success("baseRegDeleteValue")
      return self
    end

end
end

