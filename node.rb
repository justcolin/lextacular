# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

class Node
  def initialize content = ''
    @content = content
  end

  def to_s
    @content
  end

  def size
    @content.size
  end
end
