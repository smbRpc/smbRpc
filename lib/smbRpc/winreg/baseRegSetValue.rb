module SmbRpc
  class Winreg < Rpc

    class BaseRegSetValueReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpValueName
      conformantandVaryingStrings :lpValueNameNdr
      uint32 :dwType
      uint32 :maxCount, :value => lambda{ lpData.num_bytes }
      string :lpData, :read_length => :maxCount
      #pad to 4 bytes align per RPC spec
      string :pad, :onlyif => lambda{ (maxCount.value % 4) > 0}, :length => lambda { (4 - (maxCount % 4)) % 4 }
      uint32 :cbData, :value => :maxCount

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        uniString = "#{get_parameter(:valueName)}\x00".bytes.pack("v*")
        lpValueName.len.value = uniString.bytesize
        lpValueName.maximumLength.value = uniString.bytesize
        lpValueNameNdr.str.value = uniString
        dwType.value = get_parameter(:type)
        lpData.value = get_parameter(:data)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 22        #BaseRegSetValue
      end
    end

    class BaseRegSetValueRes < BinData::Record
      endian :little
      request :request
      uint32 :windowsError
    end

    def baseRegSetValue(valueName:, type:, data:)
      baseRegSetValueReq = BaseRegSetValueReq.new(handle:(@subKeyHandle || @rootKeyHandle), valueName:valueName, type:type, data:data)
      baseRegSetValueRes = @file.ioctl_send_recv(baseRegSetValueReq).buffer
      baseRegSetValueRes.raise_not_error_success("baseRegSetValue")
      return self
    end

end
end

