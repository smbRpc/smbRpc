#!/usr/bin/ruby
require"ruby_smb"
require"bindata"
require"windows_error/win32"
require"smbhash"			#nice little library to make Lm/NTLM hash
#require"windows_error/nt_status"	#already loaded by ruby_smb

$:.unshift(File.expand_path('.',__dir__))
require"smbRpc/rpc"
require"smbRpc/srvsvc"
require"smbRpc/svcctl"
require"smbRpc/lsarpc"
require"smbRpc/epmapper"
require"smbRpc/samr"
require"smbRpc/updateRuby_smb"
require"smbRpc/updateString"

#require"rpc_packet"
#require"endpoints"
#require"constants"
#require"ndrep"
#require"srvsvc_packet"
#require"svcctl_packet"

#require_relative"endpoints"
#require_relative"constants"
#require_relative"ndrep"
#require_relative"rpc"
#require_relative"rpc_packet"
#require_relative"srvsvc"
#require_relative"srvsvc_packet"
#require_relative"svcctl"
#require_relative"svcctl_packet"
