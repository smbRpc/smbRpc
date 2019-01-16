
module SmbRpc
  class Rpc
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
      result == 0? result : (raise "Connect Fail, WinError: %i"%[result])
    end

    def bind(pipe:)
      @ipc = @smb.tree_connect("\\\\#{@ip}\\IPC$")
      @file = @ipc.open_file(filename: pipe, read: true, write: true)

#p @file.bind(endpoint: SmbRpc::Svcctl)
p @file.bind(endpoint: ENDPOINT[pipe])

#p pe = PIPE[pipe]

#p @file.bind(endpoint: pe.call)


#p file.bind(endpoint: SmbRpc::Srvsvc)

#      bind = Bind.new(uuid: uuid,ver: version)
#      @file.write(data: bind.to_binary_s)
#      bind_ack = Bind_ack.read(@file.read(bytes: 0xffff))
#      result = bind_ack.p_result_list.p_result.result
#      reason = bind_ack.p_result_list.p_result.reason
      #assocGroupId =  bindAck.assoc_group_id
#      result == 0? result : (raise "Bind Fail: %s %s"%[P_CONT_DEF_RESULT_T.key(result), P_PROVIDER_REASON_T.key(reason)])
    end

    def close
      @file.close if @file != nil
      @smb.disconnect!
    end
  end
end
