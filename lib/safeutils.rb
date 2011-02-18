########################################################################
# safeutils.rb
# Copyright (c) 2007, 2011 Rob Warner
# rwarner@grailbox.com
# http://grailbox.com
# @hoop33
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
require File.join(File.dirname(__FILE__), 'safediff')
require 'highline/import'

##
# SafeUtils
# Utility methods for the Safe application
##
class SafeUtils
  # Gets the directory for the data file
  def SafeUtils.get_safe_dir(var = 'SAFE_DIR')
    dir = ENV[var]
    raise "Set environment variable #{var} to the directory for your safe file" unless dir
    begin
      d = Dir.new(dir)
    rescue
      raise "Environment variable #{var} does not point to an existing directory (#{dir})"
    end
    dir
  end
  
  # Prompts the user for a password
  def SafeUtils.get_password(prompt = 'Password: ', mask = '*')
    ask(prompt) { |q| q.echo = mask }
  end
  
  # Imports a file in the format:
  # name,ID,password
  # name,ID,password
  # etc.
  def SafeUtils.import(safe_file, import_file)
    begin
      open(import_file).each do |line|
        puts "Importing #{line}"
        fields = line.split(',')
        if fields.length == 3
          safe_file.insert(fields[0], fields[1], fields[2])
        else
          puts "Cannot import; number of fields = #{fields.length}"
        end
      end
      safe_file.save
    rescue
      puts $!
      raise "Problem importing file #{import_file}"
    end
  end

  def SafeUtils.get_safe_file(dir, prompt = 'Password: ')
    password = SafeUtils::get_password(prompt)
    SafeFile.new(password, dir)
  end

  # Diffs two .safe.xml files
  def SafeUtils.diff(safe_file, dir)
    other_file = get_safe_file(dir, "#{dir} Password: ")
    diffs = get_diffs(safe_file, other_file)
    puts diffs
  end

  # Merges two .safe.xml files
  def SafeUtils.merge(safe_file, dir)
    other_file = get_safe_file(dir, "#{dir} Password: ")
    diffs = get_diffs(safe_file, other_file)
    do_merge safe_file, diffs
    safe_file.save
  end

  # Returns the SafeDiff objects in an Array
  def SafeUtils.get_diffs(safe_file, other_file)
    diffs = Array.new

    # Find master-only and changes
    safe_file.entries.each_value do |entry|
      if other_file.entries.has_key? entry.name
        other_entry = other_file.entries[entry.name]
        diffs << SafeDiff.new(entry, other_entry) unless entry.equals? other_entry
      else
        diffs << SafeDiff.new(entry, nil)
      end
    end

    # Find other-only
    other_file.entries.each_value do |entry|
      if !safe_file.entries.has_key? entry.name
        diffs << SafeDiff.new(nil, entry)
      end
    end
    
    diffs
  end

  def SafeUtils.do_merge(safe_file, diffs, override_master = false)
    diffs.each do |diff|
      case diff.operation
      when SafeDiff::OTHER then safe_file.insert(diff.other.name, diff.other.id, diff.other.password)
      when SafeDiff::CHANGE then # Update safe file
        if override_master || replace_master?(diff)
          safe_file.insert(diff.other.name, diff.other.id, diff.other.password)
        end
      end
    end
  end

  def SafeUtils.replace_master?(diff)
    print "Replace:\n\t#{diff.master.to_s}\nWith:\n\t#{diff.other.to_s}\n?"
    gets.chomp == 'y'
  end
end
