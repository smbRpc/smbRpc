#!/usr/bin/ruby
require"smbRpc"

ip = ARGV[0]
port = 445
user = ARGV[1]
pass = ARGV[2]

svcctl = SmbRpc::Svcctl.new(ip:ip, user:user, pass:pass).openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_ENUMERATE_SERVICE"])
svcctl.enumServicesStatus.each do |i|
  puts "%s : %s\ntype: %s\nstate: %s"%[i[:displayName], i[:serviceName], SVCCTL_SERVICE_STATUS_SERVICE_TYPE.key(i[:serviceType]), 
  SVCCTL_SERVICE_STATUS_CURRENT_STATE[i[:currentState]] ]
end
svcctl.close
puts"-"*80
