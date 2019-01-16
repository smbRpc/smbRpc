require"smbRpc/epmapper/epmLookup"
require"smbRpc/epmapper/constants"

module SmbRpc
  class Epmapper < Rpc
    def initialize(**argv)
      super(argv)
      self.connect
      self.bind(pipe:"epmapper")
    end
end
end

