#!/usr/bin/ruby
require"smbRpc"

#regSave.rb 10.1.1.234 admin superSecret HkLm\\SAM C:\\sam
ip = ARGV[0]
port = 445
user = ARGV[1]
pass = ARGV[2]
key = ARGV[3]
file = ARGV[4]

splitKey = key.split("\\")
rKey = splitKey[0].upcase
sKey =  splitKey[1..-1].join("\\")

rootKeys = { 
"HKLM" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openLocalMachine, 
"HKCU" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openCurrentUser,  
"HKCR" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openClassesRoot, 
"HKU" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openUsers, 
"HKCC" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openCurrentConfig 
}

winreg = rootKeys[rKey].baseRegOpenKey(subKey:sKey).baseRegSaveKey(file:file).close
puts"%s \nsaved to\n %s"%[key, file]

