#!/usr/bin/ruby
require"smbRpc"

ip = ARGV[0]
port = 445
user = ARGV[1]
pass = ARGV[2]

samr = SmbRpc::Samr.new(ip:ip, user:user, pass:pass).connect5

domName = ""
lsarpc = SmbRpc::Lsarpc.new(ip:ip, user:user, pass:pass).openPolicy
infoPolicy = lsarpc.queryInformationPolicy	#determine if host is part of a domain
domName = infoPolicy[:dnsDomainName].nil?? samr.enumerateDomainsInSamServer[0][:domainName] : infoPolicy[:dnsDomainName]
lsarpc.close

domSid = samr.lookupDomainInSamServer(domainName:domName)

samr.openDomain(domainSid:domSid).enumerateUsersInDomain.each do |e|
  p samr.openUser(userId:e[:rid]).queryInformationUser
end
samr.close


