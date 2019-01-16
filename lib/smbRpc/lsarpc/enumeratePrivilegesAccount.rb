module SmbRpc
  class Lsarpc < Rpc

    class LsarEnumeratePrivilegesAccountReq < BinData::Record
      endian :little
      request :request
      string :accountHandle, :length => 20

      def initialize_instance
        super
        accountHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 18        #LsarEnumeratePrivilegesAccount
      end
    end

    class Lsapr_luid_and_attributes < BinData::Record
      endian :little
      string :luid, :length => 8
      uint32 :attributes		#2.2.5.4 LSAPR_LUID_AND_ATTRIBUTES
					#bit maks of last 2 least significant bit, so 1 = emable by default, 2 = enable
    end

    class Lsapr_privilege_set < BinData::Record
      endian :little
      uint32 :privilegeCount
      uint32 :numberOfPrivilegeCount
      uint32 :control
      array :privilege, :type => :lsapr_luid_and_attributes, :initial_length => :privilegeCount
    end

    class LsarEnumeratePrivilegesAccountRes < BinData::Record
      endian :little
      response :response
      uint32 :ref_id_privileges
      lsapr_privilege_set :privileges
      uint32 :windowsError
    end

    def enumeratePrivilegesAccount()
      lsarEnumeratePrivilegesAccountReq = LsarEnumeratePrivilegesAccountReq.new(handle:@accountHandle)
      lsarEnumeratePrivilegesAccountRes = @file.ioctl_send_recv(lsarEnumeratePrivilegesAccountReq).buffer
      lsarEnumeratePrivilegesAccountRes.raise_not_error_success("enumeratePrivilegesAccount")
      lsarEnumeratePrivilegesAccountRes = LsarEnumeratePrivilegesAccountRes.read(lsarEnumeratePrivilegesAccountRes)
      return lsarEnumeratePrivilegesAccountRes.privileges.privilege
    end

end
end
