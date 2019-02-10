module SmbRpc
  class Winreg < Rpc

    class BaseRegQueryValueReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      rpc_unicode_string :lpValueName
      conformantandVaryingStrings :lpValueNameNdr
      uint32 :ref_id_lpType, :value => 1
      uint32 :lpType
      uint32 :ref_id_lpData, :initial_value => 1
      conformantandVaryingStringsAscii :lpData
      uint32 :ref_id_lpcbData, :initial_value => 1
      uint32 :lpcbData
      uint32 :ref_id_lpcbLen, :initial_value => 1
      uint32 :lpcbLen

      def initialize_instance
        super

        hKey.value = get_parameter(:handle)
        uniString = "#{get_parameter(:vName)}\x00".bytes.pack("v*")
        lpValueName.len.value = uniString.bytesize
        lpValueName.maximumLength.value = uniString.bytesize
        lpValueNameNdr.str.value = uniString
        lpType.value = get_parameter(:type)
        lpData.str = ""
        lpData.max_count.value = 0x1000

        lpcbData.value = 0x1000
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 17        #BaseRegQueryValue
      end
    end

    class BaseRegQueryValueRes < BinData::Record
      endian :little
      request :request
      uint32 :ref_id_lpType
      uint32 :lpType
      uint32 :ref_id_lpData
      conformantandVaryingStringsAscii :lpData
      uint32 :ref_id_lpcbData
      uint32 :lpcbData
      uint32 :ref_id_lpcbLen
      uint32 :lpcbLen

      uint32 :windowsError
    end

    def baseRegQueryValue(valueName:, type:WINREG_REG_VALUE_TYPE["UNDEF"])
      baseRegQueryValueReq = BaseRegQueryValueReq.new(handle:(@subKeyHandle || @rootKeyHandle), vName:valueName, type:type)
      baseRegQueryValueRes = @file.ioctl_send_recv(baseRegQueryValueReq).buffer
      baseRegQueryValueRes.raise_not_error_success("baseRegQueryValue")
      baseRegQueryValueRes = BaseRegQueryValueRes.read(baseRegQueryValueRes)
      type = baseRegQueryValueRes.lpType
      data = baseRegQueryValueRes.lpData.str
      case type
        when 0
          return data
        when 1
          return data.unpack("v*").pack("c*").chop
        when 2
          return data.unpack("v*").pack("c*").chop
        when 3
          return data
        when 4
          return data.unpack("V")[0]
        when 5
          return data.unpack("N")[0] 
        when 7
          return data.unpack("v*").pack("c*").split("\x00")
        when 11
          return data.unpack("Q<")[0]
      end
    end

end
end

