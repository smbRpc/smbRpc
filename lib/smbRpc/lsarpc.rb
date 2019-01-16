require"smbRpc/lsarpc/constants"
require"smbRpc/lsarpc/openPolicy"
require"smbRpc/lsarpc/close"
require"smbRpc/lsarpc/queryInformationPolicy"
require"smbRpc/lsarpc/enumerateAccounts"
require"smbRpc/lsarpc/lookupSids"
require"smbRpc/lsarpc/openAccount"
require"smbRpc/lsarpc/enumeratePrivilegesAccount"
require"smbRpc/lsarpc/lookupPrivilegeName"
#require"smbRpc/lsarpc/querySecurityObject"
require"smbRpc/lsarpc/lookupNames"

module SmbRpc
  class Lsarpc < Rpc
    def initialize(**argv)
      super(argv)
      self.connect
      self.bind(pipe:"lsarpc")
    end
end
end

