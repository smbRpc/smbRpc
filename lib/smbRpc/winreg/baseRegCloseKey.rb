
module SmbRpc
  class Winreg < Rpc

    class BaseRegCloseKeyReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 5        #BaseRegCloseKey
      end
    end

    class BaseRegCloseKeyRes < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      uint32 :windowsError
    end

    def closeRootKey()
      if !@rootKeyHandle.nil?
        baseRegCloseKeyReq = BaseRegCloseKeyReq.new(handle:@rootKeyHandle)
        baseRegCloseKeyRes = @file.ioctl_send_recv(baseRegCloseKeyReq).buffer
        baseRegCloseKeyRes.raise_not_error_success("closeRootKey")
        baseRegCloseKeyRes = BaseRegCloseKeyRes.read(baseRegCloseKeyRes)
        @rootKeyHandle = nil
      end
    end

    def closeSubKey()
      if !@subKeyHandle.nil?
        baseRegCloseKeyReq = BaseRegCloseKeyReq.new(handle:@subKeyHandle)
        baseRegCloseKeyRes = @file.ioctl_send_recv(baseRegCloseKeyReq).buffer
        baseRegCloseKeyRes.raise_not_error_success("closeSubKey")
        baseRegCloseKeyRes = BaseRegCloseKeyRes.read(baseRegCloseKeyRes)
        @subKeyHandle = nil
      end
    end

    def close()
      closeSubKey()
      closeRootKey()
      super
    end
end
end
