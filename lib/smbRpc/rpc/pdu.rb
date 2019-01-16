
module SmbRpc
  class Rpc
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

    class Request < BinData::Record
      endian :little
      pduHead :pduHead
      uint32 :alloc_hint
      uint16 :p_cont_id
      uint16 :opnum
      string :auth_verifier, :onlyif => lambda { pduHead.auth_length > 0 }, :length => lambda { pduHead.auth_length }
      
      def initialize_instance
        super
        pduHead.ptype = PDU_TYPE["REQUEST"]
      end
    end

    class Response < BinData::Record
      endian :little
      pduHead :pduHead
      uint32 :alloc_hint
      uint16 :p_cont_id
      uint8 :cancel_count
      uint8 :reserved
      string :auth_verifier, :onlyif => lambda { pduHead.auth_length > 0 }, :length => lambda { pduHead.auth_length }
    end
  end
end
