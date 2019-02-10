require"smbRpc/winreg/constants"
require"smbRpc/winreg/openLocalMachine"
require"smbRpc/winreg/baseRegOpenKey"
require"smbRpc/winreg/baseRegQueryValue"
require"smbRpc/winreg/baseRegCloseKey"
require"smbRpc/winreg/baseRegEnumKey"
require"smbRpc/winreg/baseRegQueryInfoKey"
require"smbRpc/winreg/baseRegEnumValue"
require"smbRpc/winreg/openClassesRoot"
require"smbRpc/winreg/openCurrentUser"
require"smbRpc/winreg/openUsers"
require"smbRpc/winreg/openCurrentConfig"
require"smbRpc/winreg/baseRegCreateKey"
require"smbRpc/winreg/baseRegSetValue"
require"smbRpc/winreg/baseRegDeleteValue"
require"smbRpc/winreg/baseRegDeleteKey"
require"smbRpc/winreg/baseRegSaveKey"

module SmbRpc
  class Winreg < Rpc
    def initialize(**argv)
      super(argv)
      self.connect
      self.bind(pipe:"winreg")
    end
end
end
