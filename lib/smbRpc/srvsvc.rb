require"smbRpc/srvsvc/netShareEnum"
require"smbRpc/srvsvc/serverGetInfo"

module SmbRpc
  class Srvsvc < Rpc
    def initialize(**argv)
      super(argv)
      self.connect
      self.bind(pipe:"srvsvc")
    end
end
end
