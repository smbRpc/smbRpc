module SmbRpc
  class Winreg < Rpc

    attr_accessor :subKeyHandle

    class BaseRegOpenKeyReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpSubKey
      conformantandVaryingStrings :lpSubKeyNdr
      uint32 :dwOptions
      uint32 :samDesired

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        uniString = "#{get_parameter(:subKey)}\x00".bytes.pack("v*")
        lpSubKey.len.value = uniString.bytesize
        lpSubKey.maximumLength.value = uniString.bytesize
        lpSubKeyNdr.str.value = uniString
        dwOptions.value = get_parameter(:options)
        samDesired.value = get_parameter(:desired)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 15        #BaseRegOpenKey
      end
    end

    class BaseRegOpenKeyRes < BinData::Record
      endian :little
      request :request
      string :phkResult, :length => 20
      uint32 :windowsError
    end

    def baseRegOpenKey(subKey:, samDesired:WINREG_REGSAM["MAXIMUM_ALLOWED"], options:WINREG_OPTIONS["NONE"])
      baseRegOpenKeyReq = BaseRegOpenKeyReq.new(handle:@rootKeyHandle, subKey:subKey, desired:samDesired, options:options)
      baseRegOpenKeyRes = @file.ioctl_send_recv(baseRegOpenKeyReq).buffer
      baseRegOpenKeyRes.raise_not_error_success("baseRegOpenKey")
      baseRegOpenKeyRes = BaseRegOpenKeyRes.read(baseRegOpenKeyRes)
      @subKeyHandle = baseRegOpenKeyRes.phkResult
      return self
    end

end
end

