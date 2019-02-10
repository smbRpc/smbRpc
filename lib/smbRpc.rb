#!/usr/bin/ruby
require"ruby_smb"
require"bindata"
require"windows_error/win32"
require"smbhash"			#nice little library to make Lm/NTLM hash

#$:.unshift(File.expand_path('.',__dir__))
require"smbRpc/rpc"
require"smbRpc/srvsvc"
require"smbRpc/svcctl"
require"smbRpc/lsarpc"
require"smbRpc/epmapper"
require"smbRpc/samr"
require"smbRpc/winreg"
require"smbRpc/updateRuby_smb"
require"smbRpc/updateString"
