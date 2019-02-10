#!/usr/bin/ruby
require"smbRpc"

ip = "10.1.1.234"
port = 445
user = "admin"
pass = "sepersecret"
key = "HKLM\\HARDWARE"

splitKey = key.split("\\")
rKey = splitKey[0].upcase
sKey =  splitKey[1..-1].join("\\")

newKey = "BLA"
newValues = {
  "sz" => [ WINREG_REG_VALUE_TYPE["REG_SZ"], "abcd\x00".bytes.pack("v*")],
  "exp" => [ WINREG_REG_VALUE_TYPE["REG_EXPAND_SZ"], "System32\\Drivers\\ACPI.sys".bytes.pack("v*")],
  "bin" => [ WINREG_REG_VALUE_TYPE["REG_BINARY"], "\x23\x56\xff\xde\xed\x56\x7c\x44"],
  "dwle" => [ WINREG_REG_VALUE_TYPE["REG_DWORDLE"], "\x01\x00\x00\x00"],
  "dwbe" => [ WINREG_REG_VALUE_TYPE["REG_DWORDBE"], "\x00\x00\x00\xff"],
  "multi" => [ WINREG_REG_VALUE_TYPE["REG_MULTI_SZ"], "System32\x00Drivers\x00ACPI.sys\x00".bytes.pack("v*")],
  "qw" => [ WINREG_REG_VALUE_TYPE["REG_QWORDLE"], [4096].pack("<q")]
}

rootKeys = { 
"HKLM" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openLocalMachine, 
"HKCU" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openCurrentUser,  
"HKCR" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openClassesRoot, 
"HKU" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openUsers, 
"HKCC" =>  SmbRpc::Winreg.new(ip:ip, user:user, pass:pass).openCurrentConfig 
}

winreg = rootKeys[rKey].baseRegOpenKey(subKey:sKey)

p WINREG_DISPOSITION.key(winreg.baseRegCreateKey(subKey:newKey).disposition)		#can not create key imediately under HKLM/HKU

newValues.each do |k,v|
  winreg.baseRegSetValue(valueName:k, type:v[0], data:v[1])
  puts"%s\\%s => %s"%[key, k, v[1].inspect]
end

winreg.close


