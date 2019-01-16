
module SmbRpc
  class Svcctl < Rpc

    class QueryServiceConfigReq  < BinData::Record
      mandatory_parameter :handle
      endian :little
      request :request
      string :serviceHandle, :length => 20
      uint32 :bufSize

      def initialize_instance
        super
        serviceHandle.value = get_parameter(:handle)
        bufSize.value = get_parameter(:bytesNeeded)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 17        #RQueryServiceConfigW
      end
    end

    class Query_service_configw  < BinData::Record
      endian :little
      uint32 :serviceType
      uint32 :startType
      uint32 :errorControl
      uint32 :ref_id_binaryPathName
      uint32 :ref_id_loadOrderGroup
      uint32 :tagId
      uint32 :ref_id_dependencies
      uint32 :ref_id_serviceStartName
      uint32 :ref_id_displayName
      conformantandVaryingStrings :binaryPathName
      conformantandVaryingStrings :loadOrderGroup
      conformantandVaryingStrings :dependencies
      conformantandVaryingStrings :serviceStartName
      conformantandVaryingStrings :displayName
    end

    class QueryServiceConfigRes < BinData::Record
      endian :little
      request :response
      query_service_configw :serviceConfig
      uint32 :bytesNeeded       #bytes needed to return all data if function fail
      uint32 :windowsError
    end

    def queryServiceConfig()
      queryServiceConfigReq = QueryServiceConfigReq.new(handle:@serviceHandle, bytesNeeded:512)
      queryServiceConfigRes = @file.ioctl_send_recv(queryServiceConfigReq).buffer
      queryServiceConfigRes.raise_not_error_success("queryServiceConfig")
      queryServiceConfigRes = QueryServiceConfigRes.read(queryServiceConfigRes)
      config = queryServiceConfigRes.serviceConfig
      return {
        serviceType:config.serviceType,
        startType:config.startType,
        errorControl:config.errorControl,
        tagId:config.tagId,
        binaryPathName:config.binaryPathName.str.unpack("v*").pack("C*").chop,
        loadOrderGroup:config.loadOrderGroup.str.unpack("v*").pack("C*").chop,
        dependencies:config.dependencies.str.unpack("v*").pack("C*").chop,
        serviceStartName:config.serviceStartName.str.unpack("v*").pack("C*").chop,
        displayName:config.displayName.str.unpack("v*").pack("C*").chop
      }
    end

end
end
