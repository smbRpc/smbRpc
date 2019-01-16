#!/usr/bin/ruby
require"smbRpc"


ip = ARGV[0]
port = 445
user = ARGV[1]
pass = ARGV[2]

epmapper = SmbRpc::Epmapper.new(ip:ip, user:user, pass:pass)
epmapper.epmLookup.each do |e| 
 puts "%s %s"%[e[:uuid], e[:smb]] if !e[:smb].nil?
end

epmapper.close
puts"-"*80
