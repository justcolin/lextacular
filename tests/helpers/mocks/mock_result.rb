# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

class MockResult
  Unset = Object.new

  attr_reader :content, :name, :temp

  def initialize *content, name: Unset, temp: Unset
    @content = content
    @name    = name
    @temp    = temp
  end

  def size
    @content.size
  end
end

class MockArrayResult < MockResult
  include Enumerable

  def each &block
    @content.each(&block)
  end

  def size
    @content.map(&:size).inject(:+)
  end
end
