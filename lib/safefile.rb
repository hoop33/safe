########################################################################
# safefile.rb
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
require 'rubygems'
require 'crypt/blowfish'
require 'digest/sha2'
require 'rexml/document'
require 'fileutils'
require 'base64'

include REXML

##
# SafeFile
# The file containing the safe entries
##
class SafeFile
  attr_accessor :filename, :entries, :password
  
  def initialize(password, dir, filename = '.safe.xml')
    raise "Password must not be blank" unless password
    self.entries = Hash.new
    self.filename = "#{dir}/#{filename}"
    self.password = password
    load
  end

  # Loads the file
  def load
    f = File.open(@filename, File::CREAT)
    begin
      f.lstat.size == 0 ? create_file(f) : decrypt_file(f)
    rescue
      # TODO Determine whether error is can't create file, and print appropriate error
      raise $!
    ensure
      f.close unless f.nil?
    end
  end

  # Decrypts the file
  def decrypt_file(file)
    begin
      root = Document.new(file).root
      @salt = root.attributes["salt"]
      @hash = root.attributes["hash"]
      if authorized?
        crypt_key = Crypt::Blowfish.new(self.password)
        e_entries = root.elements["entries"]
        e_entries.elements.each("entry") do |entry|
          fields = crypt_key.decrypt_string(Base64::decode64(entry.cdatas[0].to_s)).split("\t")
          fields.length == 3 ? insert(fields[0], fields[1], fields[2]) : puts("Cannot parse #{fields}, discarding.")
        end
      else
        raise 'The password you entered is not valid'
      end
    rescue ParseException
      puts "Cannot parse #{file.path}"
    end
  end

  # Creates a new file
  def create_file(file)
    puts 'Creating new file . . .'
    generate_salt_and_hash
    save
  end

  # Saves the file
  def save
    doc = Document.new
    root = Element.new "safe"
    root.attributes["salt"] = @salt
    root.attributes["hash"] = @hash
    doc.add_element root

    crypt_key = Crypt::Blowfish.new(self.password)
    e_entries = Element.new "entries"
    @entries.each_value do |entry|
      e = Element.new "entry"
      CData.new Base64.encode64(crypt_key.encrypt_string(entry.to_s)), true, e
      e_entries.add_element e
    end
    root.add_element e_entries
    
    f = File.new(@filename, 'w')
    doc.write f, 2
    f.close
  end

  # Adds an entry
  def add(name)
    if can_insert? name
      print "#{name} User ID: "
      id = gets.chomp!
      pw = SafeUtils::get_password("#{name} Password: ")
      insert(name, id, pw)
      save
    end
  end
  
  # Inserts an entry
  def insert(name, id, pw)
    @entries.delete(name)
    @entries[name] = SafeEntry.new(name, id, pw)
  end
  
  # Determines whether we can insert this entry--if it exists, we prompt for the OK
  def can_insert?(name)
    proceed = true
    if @entries.has_key?(name)
      print "Overwrite existing #{name} (y/N)? "
      proceed = (gets.chomp == 'y')
    end
    proceed
  end

  # Deletes an entry
  def delete(name)
    if @entries.has_key?(name)
      @entries.delete(name)
      save
    else
      puts "Entry #{name} not found"
    end
  end

  # Lists the desired entries
  def list(name)
    output = Array.new
    @entries.each_value do |entry|
      # TODO Inconsistent case handling
      if name == nil || entry.name.upcase =~ /^#{name.upcase}/
        output << entry
      end
    end
    output.sort.each do |entry|
      puts entry
    end
  end

  # Returns the count of entries in the file
  def count()
    @entries.length
  end
  
  # Changes the file's password
  def change_password
    new_password = SafeUtils::get_password('Enter new password: ')
    rpt_password = SafeUtils::get_password('Confirm password: ')
    if new_password == rpt_password
      self.password = new_password
      generate_salt_and_hash
      save
    else
      puts 'Passwords do not match'
    end
  end

  def generate_salt_and_hash
    @salt = [Array.new(20){rand(256).chr}.join].pack('m').chomp
    @hash = Digest::SHA256.hexdigest(self.password + @salt)
  end
  
  # Returns whether the password is authorized
  def authorized?
    @hash == Digest::SHA256.hexdigest(self.password + @salt)
  end

  # Helper method to create an XML element with a name and text
  def create_element(name, text)
    e = Element.new name
    e.text = text
    e
  end
end  
