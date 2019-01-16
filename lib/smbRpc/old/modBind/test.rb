#!/usr/bin/ruby
require_relative"smbRpc"

#ip = "10.0.0.12"
ip = "10.1.1.128"
port = 445
user = "administrator"
pass = "pass1234"
pipe = "srvsvc"

#p rpc = SmbRpc::Rpc.new(ip:ip, port:port, user:user, pass:pass)
#p rpc.connect
#p rpc.bind(pipe:pipe)
#p rpc.close
#puts"-"*80
#srvsvc = SmbRpc::Srvsvc.new(ip:ip, port:port, user:user, pass:pass)
#srvsvc.netShareEnum.each{|i| p i}
#srvsvc.close

svcctl = SmbRpc::Svcctl.new(ip:ip, user:user, pass:pass)
#p svcctl.openScm(accessMask:ACCESS_MASK["SERVICE_ALL_ACCESS"])
#p svcctl.openScm(accessMask:ACCESS_MASK["SERVICE_QUERY_STATUS"])
#svcctl.openScm(accessMask:SmbRpc::Svcctl::ACCESS_MASK["SC_MANAGER_ENUMERATE_SERVICE"])

p svcctl.openScm(accessMask:4)

#svcctl.enumServicesStatus.each {|i| puts"%s : %s\ntype: %i\nstate: %i"%[i.displayName, i.serviceName, i.serviceType, i.currentState] }

#svcctl.enumServicesStatus.each {|i| puts"%s : %s\ntype: %s\nstate: %s\n\n"%[i.displayName, i.serviceName, SmbRpc::Svcctl::SERVICE_TYPE.key(i.serviceType), SmbRpc::Svcctl::SERVICE_STATE.key(i.currentState)] }

#p svcctl.enumServicesStatus
svcctl.close
#srvsvc.netShareEnum.each{|i| p i}

