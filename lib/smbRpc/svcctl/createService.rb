module SmbRpc
  class Svcctl < Rpc
    class CreateServiceReq < BinData::Record
      endian :little
      request :request
      string :scHandle, :length => 20
      conformantandVaryingStrings :serviceName
      uint32 :ref_id_displayName, :value => 1, :onlyif => lambda { displayLen > 0 }
      choice :displayName, :selection => lambda { displayLen } do
        conformantandVaryingStrings :default
        uint32 0
      end
      uint32 :desiredAccess
      uint32 :serviceType
      uint32 :startType
      uint32 :errorControl
      conformantandVaryingStrings :binaryPathName
      uint32 :loadOrderGroup                    #might implement this, tagId, and dependencies later
      uint32 :tagId
      uint32 :dependencies
      uint32 :dependSize
      uint32 :serviceStartName                  #not going to implement this cause ncacn_np may require password encryption
      uint32 :password                          #and default service account is LocalSystem anyway      
      uint32 :pwSize

      def initialize_instance
        super
        scHandle.value = get_parameter(:handle)
        serviceName.str = "#{get_parameter(:name)}\x00".bytes.pack("v*")
        displayName.str = "#{get_parameter(:display)}\x00".bytes.pack("v*") if displayLen > 0 #if display not empty
        binaryPathName.str = "#{get_parameter(:path)}\x00".bytes.pack("v*")
        desiredAccess.value = get_parameter(:access)
        serviceType.value = get_parameter(:type)
        startType.value = get_parameter(:start)
        errorControl.value = get_parameter(:error)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 12        #RCreateServiceW
      end

      def displayLen    		#helper method to get displayname length
        get_parameter(:display).bytesize
      end
    end

    class CreateServiceRes < BinData::Record
      endian :little
      request :response
      uint32 :tagId
      string :serviceHandle, :length => 20
      uint32 :windowsError
    end

    def createService(serviceName:, displayName:"", binaryPathName:,
      desiredAccess:SVCCTL_SERVICE_ACCESS_MASK["SERVICE_ALL_ACCESS"],
      serviceType:SVCCTL_SERVICE_STATUS_SERVICE_TYPE["SERVICE_WIN32_OWN_PROCESS"],
      startType:SVCCTL_SERVICE_START_TYPE["SERVICE_DEMAND_START"],
      errorControl:SVCCTL_SERVICE_ERROR_CONTROL["SERVICE_ERROR_NORMAL"])
      createServiceReq = CreateServiceReq.new(handle:@scHandle, name:serviceName, display:displayName, path:binaryPathName,
                                        access:desiredAccess, type:serviceType, start:startType, error:errorControl)
      createServiceRes = @file.ioctl_send_recv(createServiceReq).buffer
      createServiceRes.raise_not_error_success("createService")
      createServiceRes = CreateServiceRes.read(createServiceRes)
      @serviceHandle = createServiceRes.serviceHandle
      return self
    end

end
end
