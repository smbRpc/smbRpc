
module SmbRpc
  class Rpc

    class ConformantandVaryingStrings < BinData::Record
      endian :little
      uint32 :max_count, :initial_value => :actual_count
      uint32 :offset
      uint32 :actual_count, :value => lambda{ str.num_bytes / 2}
      string :str, :read_length => lambda { actual_count.nonzero?? actual_count.value * 2 : 0 } 
      string :pad, :onlyif => lambda{ (str.num_bytes % 4) > 0 }, :length => lambda { (4 - (str.num_bytes % 4)) % 4 }
    end

    class ConformantandVaryingStringsAscii < BinData::Record
      endian :little
      uint32 :max_count, :initial_value => :actual_count
      uint32 :offset
      uint32 :actual_count, :value => lambda{ str.num_bytes }
      string :str, :read_length => :actual_count 
      string :pad, :onlyif => lambda{ (str.num_bytes % 4) > 0}, :length => lambda { (4 - (str.num_bytes % 4)) % 4 }
    end

  end
end
