
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
