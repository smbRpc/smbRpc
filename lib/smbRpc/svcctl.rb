require"smbRpc/svcctl/closeService"
require"smbRpc/svcctl/controlService"
require"smbRpc/svcctl/deleteService"
require"smbRpc/svcctl/openScm"      
require"smbRpc/svcctl/queryServiceConfig"
require"smbRpc/svcctl/constants"
require"smbRpc/svcctl/createService"   
require"smbRpc/svcctl/enumServicesStatus"  
require"smbRpc/svcctl/openService"  
require"smbRpc/svcctl/startService"

module SmbRpc
  class Svcctl < Rpc
    def initialize(**argv)
      super(argv)
      self.connect
      self.bind(pipe:"svcctl")
    end
end
end
