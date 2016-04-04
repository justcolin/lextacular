# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  # A leaf in the abstract syntax tree
  class Node
    def initialize content = '', &block
      @content = content
    end

    def to_s
      @content
    end

    def size
      @content.size
    end
  end

  # Wrapper around multiple ordered Nodes and GroupNodes
  class GroupNode
    def initialize *children, &block
      @children = children
    end

    def to_s
      @children.map(&:to_s).join
    end

    def size
      @children.map(&:size).inject(&:+) || 0
    end
  end

  # A GroupNode that can be splatted into other nodes
  class TempGroupNode < GroupNode
    def to_a
      @children
    end
  end
end
