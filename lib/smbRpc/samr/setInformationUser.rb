
module SmbRpc
  class Samr < Rpc

    class SamrSetInformationUser2Req < BinData::Record
      endian :little
      request :request
      string :userHandle, :length => 20
      uint16 :userInformationClass, :value => 21	#UserAllInformation
      uint16 :switch, :value => :userInformationClass	#declared in samr/queryInformationUser.rb
      sampr_user_all_information :buffer

      def initialize_instance
        super
        userHandle.value = get_parameter(:handle)
        session_key = get_parameter(:session_key)
        password = get_parameter(:pass)

        if password.bytesize > 0
          buffer.ntOwfPassword.len = 16
          buffer.ntOwfPassword.maximumLength = 16
          buffer.ntPasswordPresent.value = 1
          buffer.whichFields.ntPasswordPresent.value = 1
          buffer.lmOwfPassword.len = 16
          buffer.lmOwfPassword.maximumLength = 16
          buffer.lmPasswordPresent.value = 1
          buffer.whichFields.lmPasswordPresent.value = 1
          buffer.ntOwfPasswordNdr.str = [Smbhash.ntlm_hash(password)].pack("H*").to_des_ecb_lm(session_key)
          buffer.lmOwfPasswordNdr.str = [Smbhash.lm_hash(password)].pack("H*").to_des_ecb_lm(session_key)
        end

        buffer.userAccountControl.value = get_parameter(:accControl)
        buffer.whichFields.userAccountControl.value = 1 if buffer.userAccountControl.value > 0
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 58        		#SamrSetInformationUser2
      end
    end

    class SamrSetInformationUser2Res < BinData::Record
      endian :little
      request :request
      uint32 :windowsError
    end

    def setInformationUser(password:"", userAccountControl:0)
      samrSetInformationUser2Req = SamrSetInformationUser2Req.new(handle:@userHandle, session_key:self.smb.session_key, pass:password, accControl:userAccountControl)
      samrSetInformationUser2Res = @file.ioctl_send_recv(samrSetInformationUser2Req).buffer
      samrSetInformationUser2Res.raise_not_error_success("setInformationUser")
      return self
    end

end
end
