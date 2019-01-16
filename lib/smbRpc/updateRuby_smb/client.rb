module RubySMB
  class Client

    def send_recv(packet)
      case packet.packet_smb_version
      when 'SMB1'
        packet.smb_header.uid = user_id if user_id
        packet = smb1_sign(packet)
      when 'SMB2'
        packet = increment_smb_message_id(packet)
        packet.smb2_header.session_id = session_id
        unless packet.is_a?(RubySMB::SMB2::Packet::SessionSetupRequest)
          packet = smb2_sign(packet)
        end
      else
        packet = packet
      end
      dispatcher.send_packet(packet)
      raw_response = dispatcher.recv_packet

      #fix ioctl_send_recv() raise error when receive STATUS_PENDING
      #force repeat read request if server sends NtStatus STATUS_PENDING
      raw_response = dispatcher.recv_packet if raw_response[8,4].unpack("V")[0] == WindowsError::NTStatus::STATUS_PENDING.value

      self.sequence_counter += 1 if signing_required && !session_key.empty?
      raw_response
    end
  end
end
