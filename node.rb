# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

class Node
  def initialize content = '', &block
    @content = content
    instance_eval &block if block_given?
  end

  def to_s
    @content
  end

  def size
    @content.size
  end
end
