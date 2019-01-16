module SmbRpc
  class Svcctl < Rpc
    class EnumServicesStatusReq < BinData::Record
      default_parameter :bytesNeeded => 0
      endian :little
      request :request
      string :scHandle, :length => 20
      uint32 :serviceType
      uint32 :serviceState
      uint32 :bufSize
      uint32 :ref_id_resume, :value => 1
      uint32 :resume_handle

      def initialize_instance
        super
        scHandle.value = get_parameter(:handle)
        bufSize.value = get_parameter(:bytesNeeded)
        serviceType.value = get_parameter(:type)
        serviceState.value = get_parameter(:state)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 14        #REnumServicesStatusW
      end
    end

    class Service_status < BinData::Record
      endian :little
      uint32 :ref_id_serviceName
      uint32 :ref_id_displayName
      uint32 :serviceType               #SERVICE_STATUS nested struct begin
      uint32 :currentState              #different from SmbRpc::Svcctl::SERVICE_STATE
      uint32 :controlsAccepted
      uint32 :win32ExitCode
      uint32 :serviceSpecificExitCode
      uint32 :checkPoint
      uint32 :waitHint                  #SERVICE_STATUS nested struct ends
      string :serviceName
      string :displayName
    end
 
    class Enum_service_statusw < BinData::Record
      array :service_status_array, :type => :service_status, :initial_length => :servicesReturned
    end

    class EnumServicesStatusRes < BinData::Record
      endian :little
      request :response
      uint32 :buffLen
      string :buffer, :onlyif => lambda{ buffLen > 0 }, :read_length => :buffLen
      uint32 :bytesNeeded
      uint32 :servicesReturned
      uint32 :ref_id_resumeIndex
      uint32 :resumeIndex
      uint32 :windowsError

    def getService
        enum_service_statusw = Enum_service_statusw.new(:servicesReturned => self.servicesReturned)
        enum_service_statusw.read(self.buffer)
        num = self.servicesReturned * 36
        serviceStr = self.buffer[num..-1 ].scan(/\w.+?\x00\x00\x00/)
        len = enum_service_statusw.service_status_array.length - 1      #get service array index
        len.downto(0).each do |idx|     #lopp backward b/c MS thaough it was cool to add a buffer in the middle of struct :(
          enum_service_statusw.service_status_array[idx].displayName = serviceStr.pop.unpack("v*").pack("C*").chop
          enum_service_statusw.service_status_array[idx].serviceName = serviceStr.pop.unpack("v*").pack("C*").chop
        end
        return enum_service_statusw.service_status_array
      end
    end

    #[MS-SCMR] SC_MANAGER_ENUMERATE_SERVICE access right MUST have been granted to the caller when the RPC context handle 
    #to the service record was created
    def enumServicesStatus(type:SVCCTL_SERVICE_TYPE["ALL"], state:SVCCTL_SERVICE_STATE["SERVICE_STATE_ALL"])
      services = []
      response = ""
      idx = 0
      loop do
        enumServicesStatusReq = EnumServicesStatusReq.new(handle:@scHandle, bytesNeeded:512, type:type, state:state)
        enumServicesStatusReq.resume_handle = idx
        enumServicesStatusRes = @file.ioctl_send_recv(enumServicesStatusReq).buffer
        response = enumServicesStatusRes
        enumServicesStatusRes = EnumServicesStatusRes.read(enumServicesStatusRes)
        idx = enumServicesStatusRes.resumeIndex
        enumServicesStatusRes.getService.each do |i|
        services << { serviceType:i.serviceType, currentState:i.currentState,
                      controlsAccepted:i.controlsAccepted, win32ExitCode:i.win32ExitCode,
                      serviceSpecificExitCode:i.serviceSpecificExitCode, checkPoint:i.checkPoint,
                      waitHint:i.waitHint, serviceName:i.serviceName, displayName:i.displayName
                    }
        end
        break if enumServicesStatusRes.windowsError == 0 || enumServicesStatusRes.windowsError != 234
      end
      response.raise_not_error_success("enumServicesStatus")
      return services
    end

end
end
