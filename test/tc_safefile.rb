########################################################################
# tc_safefile.rb
# Copyright (c) 2007 Rob Warner. 
# All rights reserved. This program and the accompanying materials 
# are made available under the terms of the Eclipse Public License v1.0 
# which accompanies this distribution, and is available at 
# http://www.eclipse.org/legal/epl-v10.html 
########################################################################

require File.join(File.dirname(__FILE__), '..', 'lib', 'safefile')
require File.join(File.dirname(__FILE__), '..', 'lib', 'safeentry')
require 'test/unit'
require 'fileutils'

class SafeFileTest < Test::Unit::TestCase
  def test_insert_and_delete
    f = SafeFile.new("password", ".")
    assert_equal "./.safe.xml", f.filename
    assert_equal 0, f.entries.length
    
    f.insert('apple', 'baker', 'charlie')
    assert_equal 1, f.entries.length

    f.insert('apple', 'charlie', 'baker')
    assert_equal 1, f.entries.length

    f.insert('foo', 'bar', 'baz')
    assert_equal 2, f.entries.length
    
    f.delete('bar')
    assert_equal 2, f.entries.length
    
    f.delete('foo')
    assert_equal 1, f.entries.length
    
    f.delete('apple')
    assert_equal 0, f.entries.length
    
    f.delete('apple')
    assert_equal 0, f.entries.length

    FileUtils::rm("./.safe.xml")
  end
  
  def test_add
    f = SafeFile.new("password", ".")
    f.insert('apple', 'baker', 'charlie')
    f.save
    assert_equal 1, f.count

    f1 = SafeFile.new("password", ".")
    assert_equal 1, f1.count

    FileUtils::rm("./.safe.xml")
  end
  
  def test_entry
    f = SafeFile.new("password", ".")
    f.insert('apple', 'baker', 'charlie')
    e = f.entries['apple']
    assert_equal 'apple', e.name
    assert_equal 'baker', e.id
    assert_equal 'charlie', e.password
    assert_equal "apple\tbaker\tcharlie", e.to_s

    FileUtils::rm("./.safe.xml")
  end

  def test_modify_entry
    f = SafeFile.new("password", ".")
    f.insert('apple', 'baker', 'charlie')
    e = f.entries['apple']
    assert_equal 'apple', e.name
    assert_equal 'baker', e.id
    assert_equal 'charlie', e.password
    assert_equal "apple\tbaker\tcharlie", e.to_s
    
    f.insert('apple', 'foo', 'bar')
    e = f.entries['apple']
    assert_equal 'apple', e.name
    assert_equal 'foo', e.id
    assert_equal 'bar', e.password
    assert_equal "apple\tfoo\tbar", e.to_s
    
    FileUtils::rm("./.safe.xml")
  end
    
  def test_authorized
    f = SafeFile.new("password", ".")
    assert_equal true, f.authorized?
    
    f.password = "foo"
    assert_equal false, f.authorized?

    FileUtils::rm("./.safe.xml")
  end
  
  def test_count
    f = SafeFile.new("password", ".")
    
    assert_equal 0, f.count
    
    f.insert('apple', 'baker', 'charlie')
    assert_equal 1, f.count
    
    f.insert('apple1', 'baker', 'charlie')
    assert_equal 2, f.count

    f.insert('apple1', 'baker', 'charlie')
    assert_equal 2, f.count
    
    f.insert('apple2', 'baker', 'charlie')
    assert_equal 3, f.count
    
    f.delete('apple')
    assert_equal 2, f.count
    
    f.delete('apple')
    assert_equal 2, f.count

    f.delete('apple1')
    assert_equal 1, f.count

    f.delete('apple2')
    assert_equal 0, f.count

    f.delete('apple2')
    assert_equal 0, f.count

    FileUtils::rm("./.safe.xml")
  end
end
