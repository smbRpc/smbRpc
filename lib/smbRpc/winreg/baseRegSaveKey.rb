module SmbRpc
  class Winreg < Rpc

    class BaseRegSaveKeyReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpFile
      conformantandVaryingStrings :lpFileNdr
      uint32 :pSecurityAttributes

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        uniString = "#{get_parameter(:file)}\x00".bytes.pack("v*")
        lpFile.len.value = uniString.bytesize
        lpFile.maximumLength.value = uniString.bytesize
        lpFileNdr.str.value = uniString
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 20        #BaseRegSaveKey
      end
    end

    class BaseRegSaveKeyRes < BinData::Record
      endian :little
      request :request
      uint32 :windowsError
    end

    def baseRegSaveKey(file:)
      baseRegSaveKeyReq = BaseRegSaveKeyReq.new(handle:(@subKeyHandle || @rootKeyHandle), file:file)
      baseRegSaveKeyRes = @file.ioctl_send_recv(baseRegSaveKeyReq).buffer
      baseRegSaveKeyRes.raise_not_error_success("baseRegSaveKey")
      return self
    end

end
end

