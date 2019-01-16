module SmbRpc
  class Srvsvc < Rpc
    def initialize(ip:, port:, user:"", pass:"")
      super(ip:ip, port:port, user:user, pass:pass)
      self.connect
      self.bind(pipe:"srvsvc")
    end

    def netShareEnum
      shareEnumReq = NetShareEnumReq.new(:serverName=> @ip)
      shareEnumRes = @file.ioctl_send_recv(shareEnumReq).buffer
      shares = NetShareEnumRes.read(shareEnumRes)
      out = []
      numShare = shares.share_enum_struct.share_info_container.entriesRead
      shi1_container = shares.share_enum_struct.share_info_container
      numShare.times do |i|
        type =  shi1_container.share_info_entries.shi1_type[i]
        shareName = shi1_container.share_info_entries.netname_remark[i].netname.str.unpack("v*").pack("c*").chop
        remark = shi1_container.share_info_entries.netname_remark[i].remark.str.unpack("v*").pack("c*").chop
        out << {shareName:shareName, remark:remark, type:type}
      end
      return out
    end
  end
end