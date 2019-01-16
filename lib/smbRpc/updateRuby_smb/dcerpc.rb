module RubySMB
  module SMB2
    module Dcerpc

      def ioctl_send_recv(action, options={})
	#update ioctl_send_recv to use the new RubySMB::SMB2::Packet::IoctlRequest2 structure and avoid `ioctl_send_recv': STATUS_BUFFER_OVERFLOW
        request = set_header_fields(RubySMB::SMB2::Packet::IoctlRequest2.new(options))
        request.ctl_code = 0x0011C017
        request.flags.is_fsctl = 0x00000001
        request.buffer = action.to_binary_s
        ioctl_raw_response = @tree.client.send_recv(request)
        ioctl_response = RubySMB::SMB2::Packet::IoctlResponse.read(ioctl_raw_response)
        unless ioctl_response.valid?
          raise RubySMB::Error::InvalidPacket.new(
            expected_proto: RubySMB::SMB2::SMB2_PROTOCOL_ID,
            expected_cmd:   RubySMB::SMB2::Packet::IoctlRequest::COMMAND,
            received_proto: ioctl_response.smb2_header.protocol,
            received_cmd:   ioctl_response.smb2_header.command
          )
        end
        unless ioctl_response.status_code == WindowsError::NTStatus::STATUS_SUCCESS
          raise RubySMB::Error::UnexpectedStatusCode, ioctl_response.status_code.name
        end
        ioctl_response
      end

    end
  end
end

