module SmbRpc
  class Winreg < Rpc
    attr_reader :disposition

    class BaseRegCreateKeyReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpSubKey
      conformantandVaryingStrings :lpSubKeyNdr
      rpc_unicode_string :lpClass
      uint32 :dwOptions
      uint32 :samDesired
      uint32 :lpSecurityAttributes
      uint32 :ref_id_lpdwDisposition, :initial_value => 1
      uint32 :lpdwDisposition
      
      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        uniString = "#{get_parameter(:name)}\x00".bytes.pack("v*")
        lpSubKey.len.value = uniString.bytesize
        lpSubKey.maximumLength.value = uniString.bytesize
        lpSubKeyNdr.str.value = uniString
        lpClass.len.value = 0
        lpClass.maximumLength.value = 0
        lpClass.ref_id_buffer.value = 0
        dwOptions.value = get_parameter(:options)
        samDesired.value = get_parameter(:desired)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 6        #BaseRegCreateKey
      end
    end

    class BaseRegCreateKeyRes < BinData::Record
      endian :little
      request :request
      string :phkResult, :length => 20      
      uint32 :ref_id_lpdwDisposition
      uint32 :lpdwDisposition
      uint32 :windowsError
    end

    #https://msdn.microsoft.com/en-us/library/cc244922.aspx
    #can not create remote key imediately under HKLM/HKU, will get ERROR_INVALID_PARAMETER
    def baseRegCreateKey(subKey:, samDesired:WINREG_REGSAM["MAXIMUM_ALLOWED"], options:WINREG_OPTIONS["NONE"])
      baseRegCreateKeyReq = BaseRegCreateKeyReq.new(handle:(@subKeyHandle || @rootKeyHandle), name:subKey, desired:samDesired, options:options)
      baseRegCreateKeyRes = @file.ioctl_send_recv(baseRegCreateKeyReq).buffer
      baseRegCreateKeyRes.raise_not_error_success("baseRegCreateKey")
      baseRegCreateKeyRes = BaseRegCreateKeyRes.read(baseRegCreateKeyRes)
      @disposition = baseRegCreateKeyRes.lpdwDisposition
      @subKeyHandle = baseRegCreateKeyRes.phkResult
      return self
    end

end
end

