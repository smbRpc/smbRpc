module SmbRpc
  class Winreg < Rpc

    class BaseRegEnumValueReq < BinData::Record
      endian :little
      request :request
      string :hKey, :length => 20
      uint32 :dwIndex
      rpc_unicode_string :lpValueNameIn
      conformantandVaryingStrings :lpValueNameInNdr
      uint32 :ref_id_lpType, :value => 1
      uint32 :lpType
      uint32 :ref_id_lpData, :initial_value => 0
      uint32 :ref_id_lpcbData, :initial_value => 0
      uint32 :ref_id_lpcbLen, :initial_value => 0

      def initialize_instance
        super
        hKey.value = get_parameter(:handle)
        dwIndex.value = get_parameter(:index)
        #https://support.microsoft.com/en-us/help/256986/windows-registry-information-for-advanced-users
        maxValueNameLen = 0x100
        lpValueNameIn.len.value = maxValueNameLen
        lpValueNameIn.maximumLength.value = maxValueNameLen
        lpValueNameInNdr.str = "\x00" * maxValueNameLen		#this is so weird :_
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 10        #BaseRegEnumValue
      end
    end

    class BaseRegEnumValueRes < BinData::Record
      endian :little
      request :request
      rpc_unicode_string :lpValueNameOut
      conformantandVaryingStrings :lpValueNameOutNdr
      uint32 :ref_id_lpType, :value => 1
      uint32 :lpType
      uint32 :lpData
      uint32 :lpcbData
      uint32 :lpcbLen
      uint32 :windowsError
    end

    def baseRegEnumValue(index:)
      baseRegEnumValueReq = BaseRegEnumValueReq.new(handle:(@subKeyHandle || @rootKeyHandle), index:index)
      baseRegEnumValueRes = @file.ioctl_send_recv(baseRegEnumValueReq).buffer
      baseRegEnumValueRes.raise_not_error_success("baseRegEnumValue")
      baseRegEnumValueRes = BaseRegEnumValueRes.read(baseRegEnumValueRes)
      valueName = baseRegEnumValueRes.lpValueNameOutNdr.str.unpack("v*").pack("c*").chop
      return { :valueName => valueName,
               :type => baseRegEnumValueRes.lpType.to_i
      }
    end

end
end

