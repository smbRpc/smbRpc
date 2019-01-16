module SmbRpc
  class Samr < Rpc

    class SamrQueryInformationUser2Req < BinData::Record
      endian :little
      request :request
      string :userHandle, :length => 20
      uint16 :userInformationClass, :value => 21	#18, 23, 24, 25, 26 will return STATUS_INVALID_INFO_CLASS
							#21 works but not returning passwords related fileds.  Others are just sub set of 21
      def initialize_instance
        super
        userHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 47        		#SamrQueryInformationUser2
      end
    end

    #MS-SAMR 2.2.7.5 SAMPR_LOGON_HOURS
    class Sampr_logon_hours < BinData::Record
      endian :little
      uint32 :unitsPerWeek
      uint32 :ref_id_logonHours
    end

    #MS-SAMR 2.2.7.6 SAMPR_USER_ALL_INFORMATION
    class Sampr_user_all_information < BinData::Record
      endian :little

      uint64 :lastLogon
      uint64 :lastLogoff
      uint64 :passwordLastSet
      uint64 :accountExpires
      uint64 :passwordCanChange
      uint64 :passwordMustChange 

      rpc_unicode_string :userName
      rpc_unicode_string :fullName
      rpc_unicode_string :homeDirectory
      rpc_unicode_string :homeDirectoryDrive
      rpc_unicode_string :scriptPath
      rpc_unicode_string :profilePath
      rpc_unicode_string :adminComment
      rpc_unicode_string :workStations
      rpc_unicode_string :userComment
      rpc_unicode_string :parameters
      rpc_unicode_string :lmOwfPassword
      rpc_unicode_string :ntOwfPassword
      rpc_unicode_string :privateData

      uint32 :numberOfsecurityDescriptor	#not used
      uint32 :securityDescriptor		#not used

      uint32 :userId
      uint32 :primaryGroupId
      uint32 :userAccountControl

#      uint32 :whichFields			#control which which filed to ignire (aka Ndr field) see MS-SAMR 2.2.1.8 USER_ALL Values
      struct :whichFields do
        endian :little

        #reverse bit order in each byte to maintain little endian
         bit1 :homeDirectoryDrive
         bit1 :homeDirectory
         bit1 :userComment
         bit1 :adminComment

         bit1 :primaryGroupid
         bit1 :userId
         bit1 :fullName
         bit1 :userName
         #
         bit1 :logonCount
         bit1 :badPasswordCount
         bit1 :logonHours
         bit1 :lastLogoff
         
         bit1 :lastLogon
         bit1 :workStations
         bit1 :profilePath
         bit1 :scriptPath
         #
         bit1 :codePage
         bit1 :countryCode
         bit1 :parameters
         bit1 :userAccountControl

         bit1 :accountExpires
         bit1 :passwordLastSet
         bit1 :passwordMustChange
         bit1 :passwordCanChange
         #
         bit3 :undefined
         bit1 :securityDescriptor
         bit1 :passwordExpired
         bit1 :privateData
         bit1 :lmPasswordPresent		#not set -> ignore lmPasswordPresent filed
         bit1 :ntPasswordPresent		#not set -> ignore ntPasswordPresent filed
      end

      sampr_logon_hours :logonHours
      uint16 :badPasswordCount
      uint16 :logonCount
      uint16 :countryCode
      uint16 :codePage

      uint8 :lmPasswordPresent			#0 if ignore lmOwfPassword
      uint8 :ntPasswordPresent			#0 if ignore ntOwfPassword
      uint8 :passwordExpired
      uint8 :privateDataSensitive		#not used
#Ndr
      conformantandVaryingStrings :userNameNdr, :onlyif => lambda { userName.ref_id_buffer > 0 }	#if ref pointer is not null, then Ndr should be present
      conformantandVaryingStrings :fullNameNdr, :onlyif => lambda { fullName.ref_id_buffer > 0 }	#just because the filed is ignored according to whichFileds, 
													#doesn't mean Ndr doesnt exist
      conformantandVaryingStrings :homeDirectoryNdr, :onlyif => lambda { homeDirectory.ref_id_buffer > 0 }
      conformantandVaryingStrings :homeDirectoryDriveNdr, :onlyif => lambda { homeDirectoryDrive.ref_id_buffer > 0 }
      conformantandVaryingStrings :scriptPathNdr, :onlyif => lambda { scriptPath.ref_id_buffer > 0 }
      conformantandVaryingStrings :profilePathNdr, :onlyif => lambda { profilePath.ref_id_buffer > 0 }
      conformantandVaryingStrings :adminCommentNdr, :onlyif => lambda { adminComment.ref_id_buffer > 0 }
      conformantandVaryingStrings :workStationsNdr, :onlyif => lambda { workStations.ref_id_buffer > 0 }
      conformantandVaryingStrings :userCommentNdr, :onlyif => lambda { userComment.ref_id_buffer > 0 }
      conformantandVaryingStrings :parametersNdr, :onlyif => lambda { parameters.ref_id_buffer > 0 }
      conformantandVaryingStrings :lmOwfPasswordNdr, :onlyif => lambda { lmOwfPassword.ref_id_buffer > 0 }
      conformantandVaryingStrings :ntOwfPasswordNdr, :onlyif => lambda { ntOwfPassword.ref_id_buffer > 0 } 
      conformantandVaryingStrings :privateDataNdr, :onlyif => lambda { privateData.ref_id_buffer > 0 }
      conformantandVaryingStringsAscii :logonHoursNdr, :onlyif => lambda { logonHours.ref_id_logonHours > 0 }
    end

    class SamrQueryInformationUser2Res < BinData::Record
      endian :little
      request :request
      uint32 :ref_id_buffer
      uint32 :switch
      sampr_user_all_information :buffer
      uint32 :windowsError
    end

    def queryInformationUser
      samrQueryInformationUser2Req = SamrQueryInformationUser2Req.new(handle:@userHandle)
      samrQueryInformationUser2Res = @file.ioctl_send_recv(samrQueryInformationUser2Req).buffer
      samrQueryInformationUser2Res.raise_not_error_success("QueryInformationUser")
      samrQueryInformationUser2Res = SamrQueryInformationUser2Res.read(samrQueryInformationUser2Res)
      buffer = samrQueryInformationUser2Res.buffer
      h = {
        :rid => buffer.userId,
        :gid => buffer.primaryGroupId,
        :lastLogon => buffer.lastLogon,
        :lastLogoff => buffer.lastLogoff,
        :unitsPerWeek => buffer.logonHours.unitsPerWeek,
        :badPasswordCount => buffer.badPasswordCount,
        :logonCount => buffer.logonCount,
        :passwordLastSet => buffer.passwordLastSet,
        :passwordCanChange => buffer.passwordCanChange,
        :passwordMustChange => buffer.passwordMustChange,
        :accountExpires => buffer.accountExpires,
        :userAccountControl => buffer.userAccountControl,
        :whichFields => buffer.whichFields,
        :countryCode => buffer.countryCode,
        :codePage => buffer.codePage,
        :lmPasswordPresent => buffer.lmPasswordPresent,
        :ntPasswordPresent => buffer.ntPasswordPresent,
        :passwordExpired => buffer.passwordExpired
      }
      h[:userName] = buffer.userNameNdr.str.unpack("v*").pack("c*") if buffer.userName.ref_id_buffer > 0
      h[:fullName] = buffer.fullNameNdr.str.unpack("v*").pack("c*") if buffer.fullName.ref_id_buffer > 0
      h[:homeDirectory] = buffer.homeDirectoryNdr.str.unpack("v*").pack("c*") if buffer.homeDirectory.ref_id_buffer > 0
      h[:homeDirectoryDrive] = buffer.homeDirectoryDriveNdr.str.unpack("v*").pack("c*") if buffer.homeDirectoryDrive.ref_id_buffer > 0
      h[:scriptPath] = buffer.scriptPathNdr.str.unpack("v*").pack("c*") if buffer.scriptPath.ref_id_buffer > 0
      h[:profilePath] = buffer.profilePathNdr.str.unpack("v*").pack("c*") if buffer.profilePath.ref_id_buffer > 0
      h[:adminComment] = buffer.adminCommentNdr.str.unpack("v*").pack("c*") if buffer.adminComment.ref_id_buffer > 0
      h[:userComment] = buffer.userCommentNdr.str.unpack("v*").pack("c*") if buffer.userComment.ref_id_buffer > 0 
      h[:workStations] = buffer.workStationsNdr.str.unpack("v*").pack("c*") if buffer.workStations.ref_id_buffer > 0
      h[:parameters] = buffer.parametersNdr.str.unpack("v*").pack("c*") if buffer.parameters.ref_id_buffer > 0
      h[:logonHours] = buffer.logonHoursNdr.str if buffer.logonHours.ref_id_logonHours > 0
      h[:privateData] = buffer.privateDataNdr.str if buffer.privateData.ref_id_buffer > 0
      h[:lmOwfPassword] = buffer.lmOwfPasswordNdr.str if buffer.lmOwfPassword.ref_id_buffer > 0 
      h[:ntOwfPassword] = buffer.ntOwfPasswordNdr.str if buffer.ntOwfPassword.ref_id_buffer > 0
      return h
    end

end
end

