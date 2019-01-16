
module SmbRpc
  class Samr < Rpc

    class SamrChangePasswordUserReq < BinData::Record
      endian :little
      request :request
      string :userHandle, :length => 20

      uint32 :lmPresent, :value => 1				
      uint32 :ref_id_oldLmEncryptedWithNewLm, :value => 1
      string :oldLmEncryptedWithNewLm, :length => 16
      uint32 :ref_id_newLmEncryptedWithOldLm, :value => 1
      string :newLmEncryptedWithOldLm, :length => 16

      uint32 :ntPresent, :value => 1
      uint32 :ref_id_oldNtEncryptedWithNewNt, :value => 1
      string :oldNtEncryptedWithNewNt, :length => 16
      uint32 :ref_id_newNtEncryptedWithOldNt, :value => 1
      string :newNtEncryptedWithOldNt, :length => 16

      uint32 :ntCrossEncryptionPresent, :value => 1
      uint32 :ref_id_newNtEncryptedWithNewLm, :value => 1
      string :newNtEncryptedWithNewLm, :length => 16

      uint32 :lmCrossEncryptionPresent, :value => 1
      uint32 :ref_id_newLmEncryptedWithNewNt, :value => 1
      string :newLmEncryptedWithNewNt, :length => 16

      def initialize_instance
        super
        userHandle.value = get_parameter(:handle)
        oldPass = get_parameter(:oldPass)
        newPass = get_parameter(:newPass)
        oldLm = [Smbhash.lm_hash(oldPass)].pack("H*")
        oldNt = [Smbhash.ntlm_hash(oldPass)].pack("H*")
        newLm = [Smbhash.lm_hash(newPass)].pack("H*")
        newNt = [Smbhash.ntlm_hash(newPass)].pack("H*")
        oldLmEncryptedWithNewLm.value = oldLm.to_des_ecb_lm(newLm)
        newLmEncryptedWithOldLm.value = newLm.to_des_ecb_lm(oldLm)
        oldNtEncryptedWithNewNt.value = oldNt.to_des_ecb_lm(newNt)
        newNtEncryptedWithOldNt.value = newNt.to_des_ecb_lm(oldNt)
        newNtEncryptedWithNewLm.value = newNt.to_des_ecb_lm(newLm)
        newLmEncryptedWithNewNt.value = newLm.to_des_ecb_lm(newNt)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 38        #SamrChangePasswordUser
      end
    end

    class SamrChangePasswordUserRes < BinData::Record
      endian :little
      request :request
      uint32 :windowsError
    end

    def changePasswordUser(oldPass:, newPass:)
      samrChangePasswordUserReq = SamrChangePasswordUserReq.new(handle:@userHandle, oldPass:oldPass, newPass:newPass)
      samrChangePasswordUserRes = @file.ioctl_send_recv(samrChangePasswordUserReq).buffer
      samrChangePasswordUserRes.raise_not_error_success("changePasswordUser")
      return self
    end

end
end
