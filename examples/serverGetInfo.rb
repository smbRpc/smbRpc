#!/usr/bin/ruby
require"smbRpc"

ip = ARGV[0]
port = 445
user = ARGV[1]
pass = ARGV[2]

srvsvc = SmbRpc::Srvsvc.new(ip:ip, port:port, user:user, pass:pass)
p srvsvc.serverGetInfo
srvsvc.close
