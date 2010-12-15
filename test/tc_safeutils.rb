########################################################################
# tc_safeutils.rb
# Copyright (c) 2007 Rob Warner. 
# All rights reserved. This program and the accompanying materials 
# are made available under the terms of the Eclipse Public License v1.0 
# which accompanies this distribution, and is available at 
# http://www.eclipse.org/legal/epl-v10.html 
########################################################################

require File.join(File.dirname(__FILE__), '..', 'lib', 'safeutils')
require 'test/unit'
require 'fileutils'

class SafeUtilsTest < Test::Unit::TestCase
  def test_get_safe_dir
    ev = 'MY_SAFE_ENV_VAR'
    
    # Make sure we're not clobbering an environment variable
    temp = ENV[ev]
    assert_equal nil, temp
    
    # Test when the variable isn't set
    begin
      dir = SafeUtils::get_safe_dir(ev)
    rescue
      assert_equal "Set environment variable #{ev} to the directory for your safe file", $!.message
    end

    # Test when the directory doesn't exist
    ENV[ev] = 'Does not exist'
    begin
      dir = SafeUtils::get_safe_dir(ev)
    rescue
      assert_equal "Environment variable #{ev} does not point to an existing directory (#{ENV[ev]})", $!.message
    end

    # Test when the directory exists
    ENV[ev] = '.'
    dir = SafeUtils::get_safe_dir(ev)
    assert_equal '.', dir
    
    # Make sure the directory exists
    FileUtils::cd dir
  end

  def test_diff
    f1 = SafeFile.new("password", ".")
    f2 = SafeFile.new("password", ".", ".safe2.xml")

    f1.insert('apple', 'baker', 'charlie')
    diffs = SafeUtils.get_diffs(f1, f2)
    assert_equal 1, diffs.length
    assert_equal "m\n< apple\tbaker\tcharlie\n", diffs[0].to_s

    f2.insert('apple', 'baker', 'charlie')
    diffs = SafeUtils.get_diffs(f1, f2)
    assert_equal 0, diffs.length

    f2.insert('foo', 'bar', 'baz')
    diffs = SafeUtils.get_diffs(f1, f2)
    assert_equal 1, diffs.length
    assert_equal "o\n> foo\tbar\tbaz\n", diffs[0].to_s

    f2.insert('apple', 'ibm', 'compaq')
    f2.delete('foo')
    diffs = SafeUtils.get_diffs(f1, f2)
    assert_equal 1, diffs.length
    assert_equal "c\n< apple\tbaker\tcharlie\n---\n> apple\tibm\tcompaq\n", diffs[0].to_s
    
    FileUtils::rm("./.safe2.xml")
    FileUtils::rm("./.safe.xml")
  end

  def test_merge
    f1 = SafeFile.new("password", ".")
    f2 = SafeFile.new("password", ".", ".safe2.xml")

    f1.insert('apple', 'baker', 'charlie')
    f1.insert('one', 'baker', 'charlie')
    f1.insert('two', 'baker', 'charlie')
    f1.insert('three', 'baker', 'charlie')
    f1.insert('four', 'baker', 'charlie')
    f1.insert('five', 'baker', 'charlie')

    f2.insert('three', 'baker', 'charlie')
    f2.insert('four', 'goober', 'raisinet')
    f2.insert('five', 'coke', 'pepsi')
    f2.insert('six', 'baker', 'charlie')
    f2.insert('seven', 'baker', 'charlie')
    f2.insert('eight', 'baker', 'charlie')
    
    diffs = SafeUtils.get_diffs(f1, f2)
    SafeUtils.do_merge(f1, diffs, true)
    assert_equal 9, f1.count
    assert_equal "four\tgoober\traisinet", f1.entries['four'].to_s
    assert_equal "five\tcoke\tpepsi", f1.entries['five'].to_s

    FileUtils::rm("./.safe2.xml")
    FileUtils::rm("./.safe.xml")
  end
end
