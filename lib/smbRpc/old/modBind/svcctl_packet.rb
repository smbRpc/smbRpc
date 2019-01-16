module SmbRpc
  class Svcctl < Rpc

######
UUID = '367ABB81-9844-35F1-AD32-98F038001003'
VER_MAJOR = 2
VER_MINOR = 0
#####

ACCESS_MASK = {
  "SERVICE_ALL_ACCESS" => 0x000F01FF,
  "SERVICE_CHANGE_CONFIG" => 0x00000002,
  "SERVICE_ENUMERATE_DEPENDENTS" => 0x00000008,
  "SERVICE_INTERROGATE" => 0x00000080,
  "SERVICE_PAUSE_CONTINUE" => 0x00000040,
  "SERVICE_QUERY_CONFIG" => 0x00000001,
  "SERVICE_QUERY_STATUS" => 0x00000004,
  "SERVICE_START" => 0x00000010,
  "SERVICE_STOP" => 0x00000020,
  "SERVICE_USER_DEFINED_CONTROL" => 0x00000100,
  "SERVICE_SET_STATUS" => 0x00008000,
  "SC_MANAGER_LOCK" => 0x00000008,
  "SC_MANAGER_CREATE_SERVICE" => 0x00000002,
  "SC_MANAGER_ENUMERATE_SERVICE" => 0x00000004,
  "SC_MANAGER_CONNECT" => 0x00000001,
  "SC_MANAGER_QUERY_LOCK_STATUS" => 0x00000010,
  "SC_MANAGER_MODIFY_BOOT_CONFIG" => 0x0020
}
SERVICE_TYPE = {
"SERVICE_KERNEL_DRIVER" => 0x00000001,
"SERVICE_FILE_SYSTEM_DRIVER" => 0x00000002,
"SERVICE_WIN32_OWN_PROCESS" => 0x00000010,
"SERVICE_WIN32_SHARE_PROCESS" => 0x00000020,
"ALL" => 0x00000033
}
SERVICE_STATE = {
"SERVICE_CONTINUE_PENDING" => 0x00000005,
"SERVICE_PAUSE_PENDING" => 0x00000006,
"SERVICE_PAUSED" => 0x00000007,
"SERVICE_RUNNING" => 0x00000004,
"SERVICE_START_PENDING" => 0x00000002,
"SERVICE_STOP_PENDING" => 0x00000003,
"SERVICE_STOPPED" => 0x00000001
}

    class OpenScmReq < BinData::Record
      default_parameter :serverName => "", :accessMask => 0
      endian :little
      request :request
      uint32 :ref_id_machine_name, :value => 1 
      conformantandVaryingStrings :conformantandVaryingStrings
      uint32 :databaseName
      uint32 :desiredAccess

      def initialize_instance
        super
        conformantandVaryingStrings.str = "\\\\#{get_parameter(:serverName)}\x00".bytes.pack("v*")
        desiredAccess.value = get_parameter(:accessMask)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 15
      end
    end

    class OpenScmRes < BinData::Record
      endian :little
      response :response
      string :scHandle, :length => 20
      uint32 :windowsError
    end

    class EnumServicesStatusReq < BinData::Record
      mandatory_parameter :handle     
      default_parameter :bytesNeeded => 0
      endian :little
      request :request
      string :scHandle, :length => 20
      uint32 :serviceType, :value => 0x33	#all service type 0x01 |  0x02 | 0x10 | 0x20
      uint32 :serviceState, :value => 0x03	#SERVICE_STATE_ALL
      uint32 :bufSize
      uint32 :ref_id_resume, :value => 1
      uint32 :resume_handle
      def initialize_instance
        super
        scHandle.value = get_parameter(:handle)
        bufSize.value = get_parameter(:bytesNeeded)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 14# 26 ascii 14 = unicode
      end
    end


    class Service_status < BinData::Record
      endian :little
      uint32 :ref_id_serviceName
      uint32 :ref_id_displayName
      uint32 :serviceType
      uint32 :currentState
      uint32 :controlsAccepted
      uint32 :win32ExitCode
      uint32 :serviceSpecificExitCode
      uint32 :checkPoint
      uint32 :waitHint
      string :serviceName
      string :displayName
    end

    class Enum_service_statusw < BinData::Record
      array :service_status_array, :type => :service_status, :initial_length => :servicesReturned
      #array :serviceName, :type => :string, :initial_length => :servicesReturned
      #array :serviceDescription, :type => :string, :initial_length => :servicesReturned
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
#        serviceStr = self.buffer[num..-1 ].scan(/.+?\x00\x00\x00/)
        serviceStr = self.buffer[num..-1 ].scan(/\w.+?\x00\x00\x00/)
        enum_service_statusw.service_status_array.each do |i|
          i.serviceName = serviceStr.shift.unpack("v*").pack("C*").chop
          i.displayName = serviceStr.shift.unpack("v*").pack("C*").chop
        end
        return enum_service_statusw.service_status_array
      end
    end

  end
end
#DWORD ROpenSCManagerW(
#[in, string, unique, range(0, SC_MAX_COMPUTER_NAME_LENGTH)] SVCCTL_HANDLEW lpMachineName,
#[in, string, unique, range(0, SC_MAX_NAME_LENGTH)] wchar_t* lpDatabaseName,
#[in] DWORD dwDesiredAccess, 
#[out] LPSC_RPC_HANDLE lpScHandle
#);
