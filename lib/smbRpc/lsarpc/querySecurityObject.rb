module SmbRpc
  class Lsarpc < Rpc

    class LsarQuerySecurityObjectReq < BinData::Record
      endian :little
      request :request
      string :objectHandle, :length => 20
      uint32 :securityInformation, :initial_value => 4	#1#7 #owner, group and DACL

      def initialize_instance
        super
        objectHandle.value = get_parameter(:handle)
        request.pduHead.frag_length = self.num_bytes
        request.opnum.value = 3        			#LsarQuerySecurityObject
      end
    end


    #[MS-DTYPE] 2.4.4.1 ACE_HEADER
    class Ace < BinData::Record
      endian :little
      uint8 :aceType
      uint8 :aceFlags
      uint16 :aceSize
      string :content, :length => lambda { aceSize - 4 }
     end

    #[MS-DTYPE] 2.4.5 ACL
    class Acl < BinData::Record
      endian :little
      uint8 :aclRevision
      uint8 :sbz1					#alignment
      uint16 :aclSize
      uint16 :aceCount
      uint16 :sbz2
      array :aces, :type => :ace, :initial_length => :aceCount
    end

    class Lsapr_security_descriptor < BinData::Record
      endian :little
      uint8 :revision
      uint8 :sbz1
      uint16 :control
      uint32 :ref_id_owner
      uint32 :ref_id_group
      uint32 :ref_id_sacl
      uint32 :ref_id_dacl
      acl :dacl
    end

    class Plsapr_sr_security_descriptor < BinData::Record
      endian :little
      uint32 :len
      uint32 :ref_id_security
      uint32 :secLen
      lsapr_security_descriptor :securityDescriptor
    end

    class LsarQuerySecurityObjectRes < BinData::Record
      endian :little
      response :response
      uint32 :ref_id_SecurityDescriptor
      plsapr_sr_security_descriptor :securityDescriptor
      uint32 :windowsError
    end

    def querySecurityObject(objectHandle:)
      lsarQuerySecurityObjectReq = LsarQuerySecurityObjectReq.new(handle:objectHandle)
      lsarQuerySecurityObjectRes = @file.ioctl_send_recv(lsarQuerySecurityObjectReq).buffer
      lsarQuerySecurityObjectRes.raise_not_error_success("querySecurityObject")
      lsarQuerySecurityObjectRes = LsarQuerySecurityObjectRes.read(lsarQuerySecurityObjectRes)
    end

end
end
