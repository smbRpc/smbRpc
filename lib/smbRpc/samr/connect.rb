module SmbRpc
  class Samr < Rpc

    class SamrConnectReq < BinData::Record
      endian :little
      request :request
      uint32 :ref_id_unc, :value => 1
      conformantandVaryingStrings :serverName
      uint32 :desiredAccess
      uint32 :inVersion, :value => 1
      uint32 :switch, :value => :inVersion	#only version available, may as well use normal SamrConnect
      uint32 :revision, :value => 3
      uint32 :supportedFeatures

      def initialize_instance
        super
        serverName.str = "\\\\#{get_parameter(:srvName)}\x00".bytes.pack("v*")
        desiredAccess.value = get_parameter(:access)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 64        	#SamrConnect5
      end
    end

    class SamrConnectRes < BinData::Record
      endian :little
      request :request
      uint32 :outVersion
      uint32 :switch
      uint32 :revision
      uint32 :supportedFeatures
      string :serverHandle, :length => 20
      uint32 :windowsError
    end

    def connect5(serverName:@ip, desiredAccess:SAMR_COMMON_ACCESS_MASK["MAXIMUM_ALLOWED"])
      samrConnectReq = SamrConnectReq.new(:srvName=> serverName, access:desiredAccess)
      samrConnectRes = @file.ioctl_send_recv(samrConnectReq).buffer
      samrConnectRes.raise_not_error_success("SamConnect")
      samrConnectRes = SamrConnectRes.read(samrConnectRes)
      @serverHandle = samrConnectRes.serverHandle
      return self
      end

end
end

