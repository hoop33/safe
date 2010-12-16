########################################################################
# tc_safediff.rb
# Copyright (c) 2007 Rob Warner.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
########################################################################

require File.join('.', File.dirname(__FILE__), '..', 'lib', 'safediff')
require 'test/unit'

class SafeDiffTest < Test::Unit::TestCase
  def test_diff
    e1 = SafeEntry.new('apple', 'baker', 'charlie')
    e2 = SafeEntry.new('apple', 'baker', 'charlie')
    e3 = SafeEntry.new('apple1', 'baker', 'charlie')
    e4 = SafeEntry.new('apple', 'baker1', 'charlie')
    e5 = SafeEntry.new('apple', 'baker', 'charlie1')

    # Test two equal entries
    begin
      diff = SafeDiff.new e1, e2
    rescue RuntimeError
      assert_equal "Entries are not different:\n#{e1.to_s}\n#{e2.to_s}", $!.message
    end

    # Test an OTHER
    diff = SafeDiff.new nil, e1
    assert_equal diff.operation, SafeDiff::OTHER
    assert_equal diff.to_s, "#{SafeDiff::OTHER}\n> #{e1.to_s}\n"

    # Test a MASTER
    diff = SafeDiff.new e1, nil
    assert_equal diff.operation, SafeDiff::MASTER
    assert_equal diff.to_s, "#{SafeDiff::MASTER}\n< #{e1.to_s}\n"

    # Test a change
    diff = SafeDiff.new e1, e3
    assert_equal diff.operation, SafeDiff::CHANGE
    assert_equal diff.to_s, "#{SafeDiff::CHANGE}\n< #{e1.to_s}\n---\n> #{e3.to_s}\n"

    # Test various changes
    diff = SafeDiff.new e1, e4
    assert_equal diff.operation, SafeDiff::CHANGE
    assert_equal diff.to_s, "#{SafeDiff::CHANGE}\n< #{e1.to_s}\n---\n> #{e4.to_s}\n"

    diff = SafeDiff.new e1, e5
    assert_equal diff.operation, SafeDiff::CHANGE
    assert_equal diff.to_s, "#{SafeDiff::CHANGE}\n< #{e1.to_s}\n---\n> #{e5.to_s}\n"
  end
end
