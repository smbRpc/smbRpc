module SmbRpc
  class Svcctl < Rpc
    #def initialize(ip:, port:, user:"", pass:"")
    def initialize(**argv)
      super(argv)
      self.connect
      self.bind(pipe:"svcctl")
    end

    def openScm(accessMask:)
      openScmReq = OpenScmReq.new(:serverName=> @ip, accessMask:accessMask)
      openScmRes = @file.ioctl_send_recv(openScmReq).buffer
      openScmRes = OpenScmRes.read(openScmRes)
      @scHandle = openScmRes.scHandle
      result = openScmRes.windowsError
      result == 0? result : (raise "OpenScm Fail, WinError: %i"%[result])
    end

    def enumServicesStatus()
      services = []
      idx = 0
      loop do
        enumServicesStatusReq = EnumServicesStatusReq.new(handle:@scHandle, bytesNeeded:512)
        enumServicesStatusReq.resume_handle = idx
        enumServicesStatusRes = @file.ioctl_send_recv(enumServicesStatusReq).buffer
        enumServicesStatusRes = EnumServicesStatusRes.read(enumServicesStatusRes)
        idx = enumServicesStatusRes.resumeIndex
        services += enumServicesStatusRes.getService
        break if enumServicesStatusRes.windowsError == 0 || enumServicesStatusRes.windowsError != 234
      end
      return services
    end

  end
end

