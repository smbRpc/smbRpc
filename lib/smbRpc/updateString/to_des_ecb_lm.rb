class String
  def genKeys(sevenByteStr)					#[MS-SAMR] 2.2.11.1.4
    sevenBitsArray = sevenByteStr.unpack("B*")[0].scan(/......./)	#grab each 7 bits into array
    eightBitsStr = ""						#[MS-SAMR]2.2.11.1.2 Encrypting a 64-Bit Block with a 7-Byte Key
    sevenBitsArray.each do |e|
      count = 0
      e.split("").each{ |i| count += 1 if i == "1" }		#add parity bit to each chunks (1 if sum of bits even)
      eightBitsStr << e
      eightBitsStr << (count % 2 == 0? "0" : "1")		#MS-SAMR 2.2.11.1.2 says if odd use 0???
    end
    return [eightBitsStr].pack("B*")				#pack back to 8 bytes key
  end

  def to_des_ecb_lm(key)
    #keys
    key1 = genKeys(key[0,7])
    key2 = genKeys(key[7,7])
    #hash
    hash1 = self[0,8]
    hash2 = self[8,8]
    #encrypt
    #[MS-SAMR]2.2.11 Common Algorithms
    #2.2.11.1 DES-ECB-LM
    #2.2.11.1.1 Encrypting an NT or LM Hash Value with a Specified Key
    out = ""
    desEcb = OpenSSL::Cipher.new("DES-ECB")
    desEcb.encrypt
    desEcb.key = key1
    out << desEcb.update(hash1)
    desEcb.key = key2
    out << desEcb.update(hash2)
    return out
  end
end
