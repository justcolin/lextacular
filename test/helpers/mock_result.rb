# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

class MockResult
  attr_reader :content, :metadata

  def initialize *content, **metadata
    @content  = content
    @metadata = metadata
  end
end

class EnumerableMockResult < MockResult
  include Enumerable

  def each &block
    @content.each(&block)
  end
end
