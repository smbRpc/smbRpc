This is a Windows RPC over SMB namepipe library modeled over the ruby_smb library.
All function names and arguments were written to closely reflct the originals MS documented specifications.  So if you want to know how to use it, just read the respective MS name pipe protocol documentations, see what functions I have exposed, and read the respective function definition.  
Example:
To look up names in LSA; MS-LSAD and MS-LSAT would tell you to call openPolicy then lookUpNames.  If you look in the lsarpc folder you'll see both functions available.  All you have to do is read the function definition in the file and decide what arguments you want to pass in.

lsarpc = SmbRpc::Lsarpc.new(ip:ip, user:user, pass:pass)
policy = lsarpc.openPolicy
p policy.lookupNames(name:"guest")

Currently I have only exposed some functions to the following namepipes.  I'll be adding more as I continue developing this project.

epmapper https://svn.nmap.org/nmap-exp/drazen/var/IDL/epmapper.idl?p=25000

samr [MS-SAMR]

srvsvc [MS-SRVS]

svcctl [MS-SCMR]

lsarpc [MS-LSAD] and [MS-LSAT]

Comments and suggestions are welcome, please email to rubysmbrpc@gmail.com
