########################################################################
# safediff.rb
# Copyright (c) 2007, Rob Warner
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   * Neither the name of Rob Warner nor the names of its contributors may be
#     used to endorse or promote products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
########################################################################

##
# SafeDiff
# Contains a difference between two safe entries
##
class SafeDiff
  attr_accessor :operation, :master, :other

  MASTER = "m"
  OTHER = "o"
  CHANGE = "c"

  def initialize(master, other)
    self.master = master
    self.other = other
    compare
  end

  def compare
    if self.master != nil && self.master.equals?(self.other)
      raise "Entries are not different:\n#{self.master.to_s}\n#{self.other.to_s}"
    elsif self.master != nil && self.other == nil
      self.operation = MASTER
    elsif self.master == nil && self.other != nil
      self.operation = OTHER
    else
      self.operation = CHANGE
    end
  end

  def to_s
    s = ""
    s << self.operation
    s << "\n"
    if self.operation == MASTER || self.operation == CHANGE
      s << "< "
      s << self.master.to_s
      s << "\n"
    end
    if self.operation == CHANGE
      s << "---\n"
    end
    if self.operation == OTHER || self.operation == CHANGE
      s << "> "
      s << self.other.to_s
      s << "\n"
    end
    s
  end
end
