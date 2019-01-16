#!/usr/bin/ruby
require_relative"smbRpc"
require_relative"fuzz/fuzzString"

ip = "10.0.0.7"
port = 445
user = "administrator"
pass = "pass1234"
pipe = "srvsvc"

FUZZSTR.each do |fuzz|
#(0x6F7 is thrown on an invalidly marshalled RPC packet)
  begin
    srvsvc = SmbRpc::Srvsvc.new(ip:ip, port:port, user:user, pass:pass)
    srvsvc.netShareEnumFuz(srvName:fuzz)
    srvsvc.close
    puts"-"*80
  rescue
    next
  end
end

