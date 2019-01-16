module SmbRpc
  class Svcctl < Rpc

    class ControlServiceReq  < BinData::Record
      endian :little
      request :request
      string :serviceHandle, :length => 20
      uint32 :control

      def initialize_instance
        super
        serviceHandle.value = get_parameter(:handle)
        control.value = get_parameter(:serviceControl)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 1        #RControlService
      end
    end

    class ControlServiceRes  < BinData::Record
      endian :little
      request :response
      uint32 :serviceType
      uint32 :currentState
      uint32 :controlsAccepted
      uint32 :win32ExitCode
      uint32 :serviceSpecificExitCode
      uint32 :checkPoint
      uint32 :waitHint
      uint32 :windowsError
    end

    def controlService(control:SVCCTL_SERVICE_CONTROL["SERVICE_CONTROL_INTERROGATE"]) #default to do RQueryServiceStatus
      controlServiceReq = ControlServiceReq.new(handle:@serviceHandle, serviceControl:control)
      controlServiceRes = @file.ioctl_send_recv(controlServiceReq).buffer
      controlServiceRes.raise_not_error_success("controlService")
      controlServiceRes = ControlServiceRes.read(controlServiceRes)
      return {
        serviceType:controlServiceRes.serviceType, currentState:controlServiceRes.currentState,
        controlsAccepted:controlServiceRes.controlsAccepted,
        win32ExitCode:controlServiceRes.win32ExitCode,
        serviceSpecificExitCode:controlServiceRes.serviceSpecificExitCode,
        checkPoint:controlServiceRes.checkPoint,
        waitHint:controlServiceRes.waitHint
      }
    end

end
end
