########################################################################
# tc_safeentry.rb
# Copyright (c) 2007 Rob Warner. 
# All rights reserved. This program and the accompanying materials 
# are made available under the terms of the Eclipse Public License v1.0 
# which accompanies this distribution, and is available at 
# http://www.eclipse.org/legal/epl-v10.html 
########################################################################

require File.join('.', File.dirname(__FILE__), '..', 'lib', 'safeentry')
require 'test/unit'

class SafeDirTest < Test::Unit::TestCase
  def test_to_s
    se = SafeEntry.new('name', 'id', 'password')
    assert_equal "name\tid\tpassword", se.to_s

    se = SafeEntry.new('', '', '')
    assert_equal "\t\t", se.to_s

    se = SafeEntry.new(' ', ' ', ' ')
    assert_equal " \t \t ", se.to_s
  end
  
  def test_sort
    test = Array.new
    test << SafeEntry.new('apple', 'baker', 'charlie')
    test << SafeEntry.new('zoo', 'yacht', 'x-ray')
    test << SafeEntry.new('aardvark', 'kangaroo', 'wallaby')
    test << SafeEntry.new('123', '456', '789')
    test.sort!
    assert_equal '123', test[0].name
    assert_equal 'aardvark', test[1].name
    assert_equal 'apple', test[2].name
    assert_equal 'zoo', test[3].name
  end
end
