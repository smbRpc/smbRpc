require"smbRpc/samr/connect"
require"smbRpc/samr/constants"
require"smbRpc/samr/openDomain"
require"smbRpc/samr/enumerateUsersInDomain"
require"smbRpc/samr/enumerateDomainsInSamServer"
require"smbRpc/samr/lookupDomainInSamServer"
require"smbRpc/samr/closeHandle"
require"smbRpc/samr/openUser"
require"smbRpc/samr/queryInformationUser"
require"smbRpc/samr/enumerateGroupsInDomain"
require"smbRpc/samr/enumerateAliasesInDomain"
require"smbRpc/samr/openAlias"
require"smbRpc/samr/getMembersInAlias"
require"smbRpc/samr/lookupNamesInDomain"
require"smbRpc/samr/lookupIdsInDomain"
require"smbRpc/samr/createUserInDomain"
require"smbRpc/samr/setInformationUser"
require"smbRpc/samr/deleteUser"
require"smbRpc/samr/changePasswordUser"
require"smbRpc/samr/createGroupInDomain"
require"smbRpc/samr/createAliasInDomain"
require"smbRpc/samr/deleteAlias"
require"smbRpc/samr/addMemberToAlias"
require"smbRpc/samr/getMembersInAlias"
require"smbRpc/samr/removeMemberFromAlias"
require"smbRpc/samr/openGroup"
require"smbRpc/samr/deleteGroup"
require"smbRpc/samr/addMemberToGroup"
require"smbRpc/samr/getMembersInGroup"
require"smbRpc/samr/removeMemberFromGroup"

module SmbRpc
  class Samr < Rpc
    def initialize(**argv)
      super(argv)
      self.connect
      self.bind(pipe:"samr")
    end
end
end
