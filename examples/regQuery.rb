#!/usr/bin/ruby
require"smbRpc"

#regQuery.rb 10.1.1.245 admin seperSecret HkLm\\System\\CurrentControlset\\services\\ALG

ip = ARGV[0]
port = 445
user = ARGV[1]
pass = ARGV[2]
#key = "HkLm\\System\\CurrentControlset\\services\\ALG"
key = ARGV[3]
puts"reading: %s\n\n"%[key]

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

winreg = rootKeys[rKey].baseRegOpenKey(subKey:sKey)

keyInfo = winreg.baseRegQueryInfoKey
keyInfo[:numberOfSubkeys].times do |i| 			#enum keys if subkeys count > 0
  p winreg.baseRegEnumKey(index:i)
end if keyInfo[:numberOfSubkeys] > 0

keyInfo[:numberOfValues].times do |i| 			#enum values if values count > 0
  h = winreg.baseRegEnumValue(index:i)
  puts"%s : %i : %s"%[h[:valueName], h[:type], winreg.baseRegQueryValue(valueName:h[:valueName]).inspect]
end if keyInfo[:numberOfValues] > 0

winreg.close


