module SmbRpc
  class Lsarpc < Rpc

    class LsarEnumerateAccountsReq < BinData::Record
      endian :little
      request :request
      string :policyHandle, :length => 20
      uint32 :enumerationContext
      uint32 :preferedMaximumLength, :value => 1024

      def initialize_instance
        super
        policyHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 11        #LsarEnumerateAccounts
      end
    end

    class Sid_element < BinData::Record
      endian :little
      uint32 :sub_auth
      rpc_sid :sid			#declared in lsaQueryInformationPolicy.rb
    end

    class Lsapr_account_enum_buffer < BinData::Record
      endian :little
      uint32 :entriesRead
      uint32 :ref_id_sid, :initial_value => 1
      uint32 :max_count, :value => :entriesRead
      array :ref_id_information, :initial_length => :entriesRead, :type => :uint32, :initial_value => 1
      array :information, :initial_length => :entriesRead, :type => :sid_element
    end

    class LsarEnumerateAccountsRes < BinData::Record
      endian :little
      response :response
      uint32 :enumerationContext
      lsapr_account_enum_buffer :enumerationBuffer
      uint32 :windowsError
    end

    def enumerateAccounts()
      lsarEnumerateAccountsReq = LsarEnumerateAccountsReq.new(handle:@policyHandle)
      lsarEnumerateAccountsRes = @file.ioctl_send_recv(lsarEnumerateAccountsReq).buffer
      lsarEnumerateAccountsRes.raise_not_error_success("enumerateAccounts")
      lsarEnumerateAccountsRes = LsarEnumerateAccountsRes.read(lsarEnumerateAccountsRes)
      sids = []
      lsarEnumerateAccountsRes.enumerationBuffer.information.each do |e|
        sids << e.sid.to_s
      end
      return sids
    end

end
end
