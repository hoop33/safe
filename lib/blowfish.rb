require 'openssl'

module Blowfish
  ULONG = 0x100000000

  def self.cipher(mode, key, data)
    cipher = OpenSSL::Cipher::Cipher.new('bf').send(mode)
    cipher.key = Digest::SHA256.digest(massage_key(key))
    cipher.update(data) << cipher.final
  end

  def self.encrypt(key, data)
    cipher(:encrypt, key, data)
  end

  def self.decrypt(key, text)
    cipher(:decrypt, key, text)
  end

  def self.massage_key(key)
    massaged_key = key
    keypos = 0
    0.upto(17) { |i|
      data = 0
      4.times {
        data = ((data << 8) | massaged_key[keypos].ord) % ULONG
        keypos = (keypos.next) % massaged_key.length
      }
    }
    massaged_key
  end
end
