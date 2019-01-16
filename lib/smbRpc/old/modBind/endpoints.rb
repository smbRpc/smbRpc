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
end

ENDPOINT = {
  "srvsvc" => Endpoint::Srvsvc,
  "svcctl" => Endpoint::Svcctl
}
