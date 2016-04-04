# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
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

  class GroupNode
    def initialize *children, &block
      @children = children
      instance_eval &block if block_given?
    end

    def to_s
      @children.map(&:to_s).join
    end

    def size
      @children.map(&:size).inject(&:+) || 0
    end
  end

  class TempGroupNode < GroupNode
    def to_a
      @children
    end
  end
end
