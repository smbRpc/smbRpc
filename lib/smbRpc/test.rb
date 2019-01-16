#!/usr/bin/ruby
require_relative"smbRpc"

ip = "10.0.0.7"
port = 445
user = "administrator"
#user = "mee"
pass = "pass1234"
#pipe = "srvsvc"

#p rpc = SmbRpc::Rpc.new(ip:ip, port:port, user:user, pass:pass)
#p rpc.connect
#p rpc.bind(pipe:pipe)
#p rpc.close
#puts"-"*80

=begin
srvsvc = SmbRpc::Srvsvc.new(ip:ip, port:port, user:user, pass:pass)
p srvsvc.netShareEnum
srvsvc.close
puts"-"*80
=end

=begin
svcctl = SmbRpc::Svcctl.new(ip:ip, user:user, pass:pass)
#p svcctl.openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_ALL_ACCESS"])
p svcctl.openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_ENUMERATE_SERVICE"])
svcctl.enumServicesStatus(type:SVCCTL_SERVICE_TYPE["SERVICE_FILE_SYSTEM_DRIVER"], state:SVCCTL_SERVICE_STATE["SERVICE_INACTIVE"]).each do |i| 
#  puts "%s : %s\ntype: %i, state: %i"%[i[:displayName], i[:serviceName], i[:serviceType], i[:currentState]]
  puts "%s : %s\ntype: %s\nstate: %s"%[i[:displayName], i[:serviceName], SVCCTL_SERVICE_STATUS_SERVICE_TYPE.key(i[:serviceType]), SVCCTL_SERVICE_STATUS_CURRENT_STATE[i[:currentState]] ]
#  print "%s : %i, "%[i[:displayName], i[:currentState]]
end
svcctl.close
puts"-"*80
=end

=begin
svcctl = SmbRpc::Svcctl.new(ip:ip, user:user, pass:pass)
svcctl.openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_ENUMERATE_SERVICE"])
svcctl.openService(serviceName:"srvnet", serviceAccessMask:SVCCTL_SERVICE_ACCESS_MASK["SERVICE_QUERY_CONFIG"])
p svcctl.queryServiceConfig
svcctl.closeService
svcctl.openService(serviceName:"WwanSvc", serviceAccessMask:SVCCTL_SERVICE_ACCESS_MASK["SERVICE_QUERY_CONFIG"])
p svcctl.queryServiceConfig
svcctl.closeService
svcctl.openService(serviceName:"lanmanserver", serviceAccessMask:SVCCTL_SERVICE_ACCESS_MASK["SERVICE_QUERY_CONFIG"])
p svcctl.queryServiceConfig
svcctl.close
puts"-"*80
=end

=begin
svcctl = SmbRpc::Svcctl.new(ip:ip, user:user, pass:pass)
svcctl.openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_CREATE_SERVICE"])
svcctl.createService(serviceName:"bla", displayName:"booooo....", binaryPathName:"C:\\Program File\\ipconfig.exe")
svcctl.close
puts"-"*80

sleep(1)

svcctl = SmbRpc::Svcctl.new(ip:ip, user:user, pass:pass)
#svcctl.openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_ALL_ACCESS"])
svcctl.openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_CONNECT"])
svcctl.openService(serviceName:"bla", serviceAccessMask:SVCCTL_SERVICE_ACCESS_MASK["SERVICE_ALL_ACCESS"])
p svcctl.queryServiceConfig
svcctl.deleteService
svcctl.close
puts"-"*80
=end

=begin
svcctl = SmbRpc::Svcctl.new(ip:ip, user:user, pass:pass)
svcctl.openScm(scAccessMask:SVCCTL_SC_ACCESS_MASK["SC_MANAGER_CONNECT"])
svcctl.openService(serviceName:"browser", serviceAccessMask:SVCCTL_SERVICE_ACCESS_MASK["SERVICE_ALL_ACCESS"])
p svcctl.controlService		#default control:SVCCTL_SERVICE_CONTROL["SERVICE_CONTROL_INTERROGATE"]
p svcctl.controlService(control:SVCCTL_SERVICE_CONTROL["SERVICE_CONTROL_STOP"])
sleep(2)	#give SCM time to stop service
p svcctl.startService
p svcctl.controlService
svcctl.close
puts"-"*80
=end

=begin
lsarpc = SmbRpc::Lsarpc.new(ip:ip, user:user, pass:pass)
#p lsarpc.lsaOpenPolicy
#p lsarpc.lsaQueryInformationPolicy
#p lsarpc.lsaQueryInformationPolicy(informationClass:LSARPC_POLICY_INFORMATION_CLASS["PolicyLsaServerRoleInformation"])
#p lsarpc.lsaEnumerateAccounts
#lsarpc.lsaEnumerateAccounts.each { |s| p lsarpc.lsaLookupSids(sid:s) }
#p sid = "S-1-5-21-2012463574-1003510996-3897730414-1002"
#p lsarpc.lsaLookupSids(sid:sid)
#sid bruteforce
#(1..100).each do |i|
#  begin
#    p sid = "S-1-5-21-2012463574-1003510996-3897730414-100#{i}"
#    p lsarpc.lsaLookupSids(sid:sid)
#  rescue 
#    next
#  end
#end
#lsarpc.lsaEnumerateAccounts.each do |sid|
#  lsarpc.lsaOpenAccount(desiredAccess:LSARPC_ACCOUNT_ACCESS_MASK["ACCOUNT_VIEW"], 
  #sid:"S-1-5-21-2012463574-1003510996-3897730414-1002")
#   sid:sid)
#  p lsarpc.lsaEnumeratePrivilegesAccount
#end

#lsarpc.lsaEnumerateAccounts.each do |sid|
#  p sid
#  p lsarpc.lsaLookupSids(sid:sid)
#  lsarpc.lsaOpenAccount(desiredAccess:LSARPC_ACCOUNT_ACCESS_MASK["ACCOUNT_VIEW"], sid:sid)
#  lsarpc.lsaEnumeratePrivilegesAccount.each { |e| p lsarpc.lsaLookupPrivilegeName(luid:e) }
#  puts"+"*80
#end

#p lsarpc.lsaOpenPolicy(desiredAccess:LSARPC_POLICY_ACCESS_MASK["POLICY_VIEW_LOCAL_INFORMATION"])
#p  lsarpc.lsaOpenAccount(desiredAccess:LSARPC_ACCOUNT_ACCESS_MASK["ACCOUNT_VIEW"], 
#sid:"S-1-1-0")
#sid:"S-1-5-21-2012463574-1003510996-3897730414-1002")
#sid:"S-1-5-21-2012463574-1003510996-3897730414-1001")
#lsarpc.lsaQuerySecurityObject(objectHandle:lsarpc.accountHandle)	#keep geting access denied??
#lsarpc.close
#puts"-"*80
=end


epmapper = SmbRpc::Epmapper.new(ip:ip, user:user, pass:pass)
epmapper.epmLookup.each{ |e| p e }
epmapper.close
#puts"-"*80
