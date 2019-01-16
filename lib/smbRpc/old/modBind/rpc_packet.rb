
PFC_FIRST_FRAG = 0x01
PFC_LAST_FRAG = 0x02
PFC_PENDING_CANCEL = 0x04
PFC_RESERVED_1 = 0x08
PFC_CONC_MPX = 0x10
PFC_DID_NOT_EXECUTE = 0x20
PFC_MAYBE = 0x40
PFC_OBJECT_UUID = 0x80

P_CONT_DEF_RESULT_T = {
  "ACCEPTANCE" => 0,
  "USER_REJECTION" => 1,
  "PROVIDER_REJECTION" => 2
}
P_PROVIDER_REASON_T = {
  "REASON_NOT_SPECIFIED" => 0, 
  "ABSTRACT_SYNTAX_NOT_SUPPORTED" => 1, 
  "PROPOSED_TRANSFER_SYNTAXES_NOT_SUPPORTED" => 2, 
  "LOCAL_LIMIT_EXCEEDED" => 3
}

PDU_TYPE = {
"REQUEST" => 0,
"PING" => 1,
"RESPONSE" => 2,
"FAULT" => 3,
"WORKING" => 4,
"NOCALL" => 5,
"REJECT" => 6,
"ACK" => 7,
"CL_CANCEL" => 8,
"FACK" => 9,
"CANCEL_ACK" => 10,
"BIND" => 11,
"BIND_ACK" => 12,
"BIND_NAK" => 13,
"ALTER_CONTEXT" => 14,
"ALTER_CONTEXT_RESP" => 15,
"SHUTDOWN" => 17,
"CO_CANCEL" => 18,
"ORPHANED" => 19
}

=begin
#PIPE = {

#  "srvsvc" => ["4B324FC8-1670-01D3-1278-5A47BF6EE188", 3.0],
#  "svcctl" => ["367ABB81-9844-35F1-AD32-98F038001003", 2.0]
  "srvsvc" => module SmbRpc
		class Srvsvc < Rpc
		  UUID = '4B324FC8-1670-01D3-1278-5A47BF6EE188'
		  VER_MAJOR = 3
		  VER_MINOR = 0
	        end
	      end,
  "svcctl" => module SmbRpc
		class Svcctl < Rpc
		  UUID = '367ABB81-9844-35F1-AD32-98F038001003'
		  VER_MAJOR = 2
		  VER_MINOR = 0
	        end
	      end
#"srvsvc" => lambda { UUID = "4B324FC8-1670-01D3-1278-5A47BF6EE188", VER_MAJOR = 3, VER_MINOR = 0 },
#"svcctl" => lambda { UUID = "367ABB81-9844-35F1-AD32-98F038001003", VER_MAJOR = 2, VER_MINOR = 0 }

}
=end

#SERVICE_TYPE = {
#"SERVICE_KERNEL_DRIVER" => 0x00000001,
#"SERVICE_FILE_SYSTEM_DRIVER" => 0x00000002,
#"SERVICE_WIN32_OWN_PROCESS" => 0x00000010,
#"SERVICE_WIN32_SHARE_PROCESS" => 0x00000020,
#"ALL" => 0x00000033
#}
#SERVICE_STATE = {
#"SERVICE_ACTIVE" => 0x00000001,
#"SERVICE_INACTIVE" => 0x00000002,
#"SERVICE_STATE_ALL" => 0x00000003
#}

module SmbRpc
  class Rpc
    class P_syntax_id_t < BinData::Record
      endian :little
      string :if_uuid, :length => 16
      uint16 :if_version_major
      uint16 :if_version_minor

      def ndrParse(uuidStr, ver)
        uuidArr = uuidStr.split("-")
        uuidArr[0] = uuidArr[0].to_i(16)
        uuidArr[1] = uuidArr[1].to_i(16)
        uuidArr[2] = uuidArr[2].to_i(16)
        uuidArr[3] = uuidArr[3].to_i(16)
        if_uuid.value = uuidArr.pack("VvvnH*")
        verArr = ver.to_s.split(".")
        if_version_major.value = verArr[0].to_i
        if_version_minor.value = verArr[1].to_i
      end
    end

    class PduHead < BinData::Record
      endian :little
      uint8  :rpc_vers, :initial_value => 5
      uint8  :rpc_vers_minor
      uint8  :ptype					#packet type
      uint8  :pfc_flags, :initial_value => lambda{ PFC_FIRST_FRAG | PFC_LAST_FRAG }			#flags (see PFC_... )
      uint32 :drep, :initial_value => 0x10		#NDR data representation format label
      uint16 :frag_length				#total length of the PDU
      uint16 :auth_length				#length of auth_value
      uint32 :call_id, :initial_value => 1		#call identifier for matching rewponse like smb msg ID
    end

    #12.6.4.3 The bind PDU
    class Bind < BinData::Record
      mandatory_parameter :uuid, :ver
      endian :little
      pduHead :pduHead
      uint16 :max_xmit_frag, :initial_value => 0xffff	#max transnit pdu size
      uint16 :max_recv_frag, :initial_value => 0xffff	#max receive pdu size
      uint32 :assoc_group_id				#client set to 0 indicate a new session, 
							#server returns a new one in rpc_bind_ack 
      #pContentList :p_cont_elem				#list of available presentation(OSI model) syntax(abstract/transfer)
      uint8  :n_context_elem, :initial_value => 1
      uint8 :reserved
      uint16 :reserved2
      #PContentElement
      uint16 :p_context_id
      uint8 :n_transfer_syn, :initial_value => 1
      uint8 :reserved3
      p_syntax_id_t :abstract_syntax
      p_syntax_id_t :transfer_syntax

      def initialize_instance
        super
        pduHead.frag_length = self.num_bytes
        pduHead.ptype = PDU_TYPE["BIND"]
        abstract_syntax.ndrParse(get_parameter(:uuid),get_parameter(:ver))		#set srvsvc uuid and version
        transfer_syntax.ndrParse("8a885d04-1ceb-11c9-9fe8-08002b104860", 2.0)	#set default NDR transfer syntax and version
      end
    end

    class Port_any_t < BinData::Record
      endian :little
      uint16 :len
      string :port_spec, :length => :len
    end

    class P_result_t < BinData::Record
      endian :little
      uint16 :result
      uint16 :reason
      p_syntax_id_t :transfer_syntax
    end

    class P_result_list_t < BinData::Record
      endian :little
      uint8 :n_results
      uint8 :reserved
      uint16 :reserved2
      p_result_t :p_result
    end

    class Bind_ack < BinData::Record
      endian :little
      pduHead :pduHead
      uint16 :max_xmit_frag					#max transnit pdu size
      uint16 :max_recv_frag					#max receive pdu size
      uint32 :assoc_group_id                                #new assotiation group rfom server 
      port_any_t :sec_addr
      string :pad2, :length => lambda {4 - (pad2.abs_offset % 4)}	#pad 4 bytes aligned from begin to sec_addr
      p_result_list_t :p_result_list
      string :auth_verifier, :onlyif => lambda { pduHead.auth_length > 0 }, :length => lambda { pduHead.auth_length }
    end

    class Request < BinData::Record
      endian :little
      pduHead :pduHead
      uint32 :alloc_hint
      uint16 :p_cont_id
      uint16 :opnum
      #string :object, :length => 16, :onlyif => lambda { pduHead.pfc_flags & PFC_OBJECT_UUID }
      #string :auth_verifier, :onlyif => lambda { pduHead.auth_length > 0 }, :length => lambda { pduHead.auth_length }
      def initialize_instance
        super
        pduHead.ptype = PDU_TYPE["REQUEST"]
      end
    end

    class ConformantandVaryingStrings < BinData::Record
      endian :little
      uint32 :max_count, :value => lambda{ str.num_bytes / 2}
      uint32 :offset
      uint32 :actual_count, :value => :max_count
      string :str, :read_length => lambda { if max_count.nonzero?; return max_count.value * 2; end} 
      string :pad, :onlyif => lambda{ (str.num_bytes % 4) > 0}, :length => lambda { (4 - (str.num_bytes % 4)) % 4 }
    end

    class Response < BinData::Record
      endian :little
      pduHead :pduHead
      uint32 :alloc_hint
      uint16 :p_cont_id
      uint8 :cancel_count
      uint8 :reserved
      #string :auth_verifier, :onlyif => lambda { pduHead.auth_length > 0 }, :length => lambda { pduHead.auth_length }
    end
  end
end
#PDU Type	Protocol	Type Value
#request		CO/CL		0
#ping		CL		1
#response	CO/CL		2
#fault		CO/CL		3
#working		CL		4
#nocall		CL		5
#reject		CL		6
#ack		CL		7
#cl_cancel	CL		8
#fack		CL		9
#cancel_ack	CL		10
#bind		CO		11
#bind_ack	CO		12
#bind_nak	CO		13
#alter_context	CO		14
#alter_context_resp	CO	15
#shutdown	CO		17
#co_cancel	CO		18
#orphaned	CO		19
