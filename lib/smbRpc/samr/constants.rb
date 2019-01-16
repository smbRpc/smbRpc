SAMR_SERVER_ACCESS_MASK = { 
  "SAM_SERVER_CONNECT" => 0x00000001,
  "SAM_SERVER_SHUTDOWN" => 0x00000002,
  "SAM_SERVER_INITIALIZE" => 0x00000004,
  "SAM_SERVER_CREATE_DOMAIN" => 0x00000008,
  "SAM_SERVER_ENUMERATE_DOMAINS" => 0x00000010,
  "SAM_SERVER_LOOKUP_DOMAIN" => 0x00000020,
  "SAM_SERVER_ALL_ACCESS" => 0x000F003F,
  "SAM_SERVER_READ" => 0x00020010,
  "SAM_SERVER_WRITE" => 0x0002000E,
  "SAM_SERVER_EXECUTE" => 0x00020021
}

#https://msdn.microsoft.com/en-us/library/cc230294.aspx
SAMR_COMMON_ACCESS_MASK = { 
  "GENERIC_READ" => 0x80000000,
  "GENERIC_WRITE" => 0x4000000,
  "GENERIC_EXECUTE" => 0x20000000,
  "GENERIC_ALL" => 0x10000000,
  "SYNCHRONIZE" => 0x00100000,
  "DELETE" => 0x00010000,
  "READ_CONTROL" => 0x00020000,
  "WRITE_DAC" => 0x00040000,
  "WRITE_OWNER" => 0x00080000,
  "ACCESS_SYSTEM_SECURITY" => 0x01000000,
  "MAXIMUM_ALLOWED" => 0x02000000
}

SAMR_USER_ACCOUNT = {
  "USER_ACCOUNT_DISABLED" => 0x00000001,	#account is not enabled for authentication.
  "USER_HOME_DIRECTORY_REQUIRED" => 0x00000002,	#homeDirectory attribute is required.
  "USER_PASSWORD_NOT_REQUIRED" => 0x00000004,	#password-length policy does not apply to this user.
  "USER_TEMP_DUPLICATE_ACCOUNT" => 0x00000008,	#This bit is ignored by clients and servers.
  "USER_NORMAL_ACCOUNT" => 0x00000010,		#user is not a computer object
  "USER_MNS_LOGON_ACCOUNT" => 0x00000020,	#This bit is ignored by clients and servers
  "USER_INTERDOMAIN_TRUST_ACCOUNT" => 0x00000040,	#object represents a trust object.
  "USER_WORKSTATION_TRUST_ACCOUNT" => 0x00000080,	#object is a member workstation or server.
  "USER_SERVER_TRUST_ACCOUNT" => 0x00000100,	#object is a DC
  "USER_DONT_EXPIRE_PASSWORD" => 0x00000200,	#maximum-password-age policy does not apply to this user.
  "USER_ACCOUNT_AUTO_LOCKED" => 0x00000400,	#account has been locked out
  "USER_ENCRYPTED_TEXT_PASSWORD_ALLOWED" => 0x00000800,	#cleartext password is to be persisted
  "USER_SMARTCARD_REQUIRED" => 0x00001000,	#user can authenticate only with a smart card
  "USER_TRUSTED_FOR_DELEGATION" => 0x00002000,	#used by the Kerberos protocol, "OK as Delegate" ticket flag is to be set
  "USER_NOT_DELEGATED" => 0x00004000, 		#used by the Kerberos protocol. TGTs and service tickets obtained by this account 
						#are not marked as forwardable or proxiable
  "USER_USE_DES_KEY_ONLY" => 0x00008000,	#used by the Kerberos protocol. only des-cbc-md5 or des-cbc-crc keys
  "USER_DONT_REQUIRE_PREAUTH" => 0x00010000,	#used by the Kerberos protocol. the account is not required pre-authentication data
  "USER_PASSWORD_EXPIRED" => 0x00020000,	#password age on the user has exceeded the maximum password age policy
  "USER_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION" => 0x00040000,	#used by the Kerberos protocol, in [MS-KILE] section 3.3.1.1.
  "USER_NO_AUTH_DATA_REQUIRED" => 0x00080000,	#used by the Kerberos protocol. when the KDC is issuing a service ticket 
						#the privilege attribute certificate (PAC) is not to be included
  "USER_PARTIAL_SECRETS_ACCOUNT" => 0x00100000,	#Specifies that the object is a read-only domain controller (RODC).
  "USER_USE_AES_KEYS" => 0x00200000		#This bit is ignored by clients and servers.
}

#https://msdn.microsoft.com/en-us/library/cc245770.aspx
SAMR_CREATE_USER_ACCOUNT = {
  "USER_NORMAL_ACCOUNT" => 0x00000010,          #user is not a computer object
  "USER_WORKSTATION_TRUST_ACCOUNT" => 0x00000080,       #object is a member workstation or server.
  "USER_SERVER_TRUST_ACCOUNT" => 0x00000100    #object is a DC
}

#https://msdn.microsoft.com/en-us/library/cc245525.aspx

SAMR_USER_ACCESS_MASK = { 
  "USER_READ_GENERAL" => 0x00000001,
  "USER_READ_PREFERENCES" => 0x00000002,
  "USER_WRITE_PREFERENCES" => 0x00000004,
  "USER_READ_LOGON" => 0x00000008,
  "USER_READ_ACCOUNT" => 0x00000010,
  "USER_WRITE_ACCOUNT" => 0x00000020,
  "USER_CHANGE_PASSWORD" => 0x00000040,
  "USER_FORCE_PASSWORD_CHANGE" => 0x00000080,
  "USER_LIST_GROUPS" => 0x00000100,
  "USER_READ_GROUP_INFORMATION" => 0x00000200,
  "USER_WRITE_GROUP_INFORMATION" => 0x00000400,
  "USER_ALL_ACCESS" => 0x000F07FF,
  "USER_READ" => 0x0002031A,
  "USER_WRITE" => 0x00020044,
  "USER_EXECUTE" => 0x00020041
}

SAMR_GROUP_ACCESS_MASK = {
  "GROUP_READ_INFORMATION" => 0x00000001,
  "GROUP_WRITE_ACCOUNT" => 0x00000002,
  "GROUP_ADD_MEMBER" => 0x00000004,
  "GROUP_REMOVE_MEMBER" => 0x00000008,
  "GROUP_LIST_MEMBERS" => 0x00000010,
  "GROUP_ALL_ACCESS" => 0x000F001F,
  "GROUP_READ" => 0x00020010,
  "GROUP_WRITE" => 0x0002000E,
  "GROUP_EXECUTE" => 0x00020001
}
SAMR_ALIAS_ACCESS_MASK = {
  "ALIAS_ADD_MEMBER" => 0x00000001,
  "ALIAS_REMOVE_MEMBER" => 0x00000002,
  "ALIAS_LIST_MEMBERS" => 0x00000004,
  "ALIAS_READ_INFORMATION" => 0x00000008,
  "ALIAS_WRITE_ACCOUNT" => 0x00000010,
  "ALIAS_ALL_ACCESS" => 0x000F001F,
  "ALIAS_READ" => 0x00020004,
  "ALIAS_WRITE" => 0x00020013,
  "ALIAS_EXECUTE" => 0x00020008
}
SAMR_ENUM_USER_INFORMATION_CLASS = {
  "UserAccountInformation" => 5, 
  "UserInternal1Information" => 18
}

SAMR_SE_GROUP_ATTRIBUTES = {
  "SE_GROUP_MANDATORY" => 0x00000001,
  "SE_GROUP_ENABLED_BY_DEFAULT" => 0x00000002,
  "SE_GROUP_ENABLED" => 0x00000004
}
