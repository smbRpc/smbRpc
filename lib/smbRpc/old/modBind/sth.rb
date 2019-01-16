#!/usr/bin/ruby
require"socket"
require"ruby_smb"

ip = "10.1.1.128"
port = 445
user = "administrator"
pass = "pass1234"
#pipe = "srvsvc"
pipe = "svcctl"

module SmbRpc
  module Srvsvc
    UUID = '4b324fc8-1670-01d3-1278-5a47bf6ee188'
    VER_MAJOR = 3
    VER_MINOR = 0
    #Operation numbers
    #NET_SHARE_ENUM_ALL = 0xF
  end
end

module SmbRpc
  module Svcctl
    UUID = '367ABB81-9844-35F1-AD32-98F038001003'
    VER_MAJOR = 2
    VER_MINOR = 0
    #Operation numbers
    #NET_SHARE_ENUM_ALL = 0xF
  end
end

#  "svcctl" => ["367ABB81-9844-35F1-AD32-98F038001003", 2.0]


sock = TCPSocket.open(ip, port)

      dispatcher = RubySMB::Dispatcher::Socket.new(sock)
      smb = RubySMB::Client.new(dispatcher, smb1: true, smb2: true, username: user, password: pass)
      result = smb.login.value
#      result == 0? result : (raise "Connect Fail, WinError: %i"%[result])
#p      result == 0? result : (raise "Connect Fail, WinError: %i"%[result])

p      ipc = smb.tree_connect("\\\\#{ip}\\IPC$")
p      file = ipc.open_file(filename: pipe, read: true, write: true)

#p file.bind(endpoint: SmbRpc::Srvsvc)
p file.bind(endpoint: SmbRpc::Svcctl)

smb.disconnect!
#sock.close
