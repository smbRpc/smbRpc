#!/usr/bin/ruby
require_relative"../lib/smbRpc"

ip = ARGV[0]
port = 445
user = ARGV[1]
pass = ARGV[2]

lsarpc = SmbRpc::Lsarpc.new(ip:ip, user:user, pass:pass)
policy = lsarpc.openPolicy

puts"PolicyDnsDomainInformation"
p pddi = policy.queryInformationPolicy

puts"\nPolicyLsaServerRoleInformation"
p policy.queryInformationPolicy(informationClass:LSARPC_POLICY_INFORMATION_CLASS["PolicyLsaServerRoleInformation"])

puts"\nLSA builtin Accounts"
lsarpc.enumerateAccounts.each do |sid|
  p sid
  p lsarpc.lookupSids(sid:sid)
end

if !pddi[:dnsDomainName].nil?		#if enumerating DC
  domain = pddi[:dnsDomainName] 
  domSid = policy.lookupNames(name:domain)[:sid]
else					#else workstation
  domSid = policy.lookupNames(name:"guest")[:sid]
end

puts"\nrid 1000-1500"
(1000..1500).each do |i|
  begin
    sid = "%s-%i"%[domSid, i] 
    out = lsarpc.lookupSids(sid:sid)
    (print"%s -> "%[sid];p out; puts"") if !out.nil?
  rescue
    next
  end
end

lsarpc.close
puts"-"*80

