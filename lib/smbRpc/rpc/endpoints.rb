module SmbRpc
  module Endpoint
    module Srvsvc
      UUID = '4B324FC8-1670-01D3-1278-5A47BF6EE188'
      VER_MAJOR = 3
      VER_MINOR = 0
    end
    module Svcctl
      UUID = '367ABB81-9844-35F1-AD32-98F038001003'
      VER_MAJOR = 2
      VER_MINOR = 0
    end
    module Lsarpc
      UUID = '12345778-1234-ABCD-EF00-0123456789AB'
      VER_MAJOR = 0
      VER_MINOR = 0
    end
    module Epmapper
      UUID = 'e1af8308-5d1f-11c9-91a4-08002b14a0fa'
      VER_MAJOR = 3
      VER_MINOR = 0
    end
    module Samr
      UUID = '12345778-1234-ABCD-EF00-0123456789AC'
      VER_MAJOR = 1
      VER_MINOR = 0
    end
  end
end

ENDPOINT = {
  "srvsvc" => SmbRpc::Endpoint::Srvsvc,
  "svcctl" => SmbRpc::Endpoint::Svcctl,
  "lsarpc" => SmbRpc::Endpoint::Lsarpc,
  "epmapper" => SmbRpc::Endpoint::Epmapper,
  "samr" => SmbRpc::Endpoint::Samr
}

