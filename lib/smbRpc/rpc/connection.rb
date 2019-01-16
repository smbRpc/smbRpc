
module SmbRpc
  class Rpc

  attr_reader :smb

    def initialize(ip:, port:445, user:"", pass:"")
      @ip = ip
      @port = port
      @user = user
      @pass = pass
    end

    def connect
      sock = TCPSocket.open(@ip, @port)
      dispatcher = RubySMB::Dispatcher::Socket.new(sock)
      @smb = RubySMB::Client.new(dispatcher, smb1: true, smb2: true, username: @user, password: @pass)
      result = @smb.login.value 
      error = WindowsError::NTStatus.find_by_retval(result.to_i)[0]
      result == 0? result : (raise "Connect Fail, WinError: %s %s"%[error.name, error.description])
    end

    def bind(pipe:)
      @ipc = @smb.tree_connect("\\\\#{@ip}\\IPC$")
      @file = @ipc.open_file(filename: pipe, read: true, write: true)
      @file.bind(endpoint: ENDPOINT[pipe])	#ruby_smb bind uses modules as endpoints, so setup and give it one
    end

    def close
      @file.close if @file != nil
      @smb.disconnect!
    end
  end
end
