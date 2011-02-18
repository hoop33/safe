module Crypt
  class Blowfish
    def setup_blowfish()
      @sBoxes = Array.new(4) { |i| INITIALSBOXES[i].clone }                                                                                                                                                     
      @pArray = INITIALPARRAY.clone
      keypos = 0
      0.upto(17) { |i|
        data = 0
        4.times {
          data = ((data << 8) | @key[keypos].ord) % ULONG
          keypos = (keypos.next) % @key.length
        }
        @pArray[i] = (@pArray[i] ^ data) % ULONG
      }
      l = 0
      r = 0
      0.step(17, 2) { |i|
        l, r = encrypt_pair(l, r)
        @pArray[i]   = l
        @pArray[i+1] = r
      }
      0.upto(3) { |i|
        0.step(255, 2) { |j|                                                                                                                                                                                    
          l, r = encrypt_pair(l, r)
          @sBoxes[i][j]   = l
          @sBoxes[i][j+1] = r
        }
      }
    end
  end
end
