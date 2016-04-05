# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  # Wrapper around multiple ordered Tokens and Expression
  class Expression
    attr_reader :children

    def initialize *children, &block
      @children = children
    end

    def content
      @children.map(&:content).join
    end

    def size
      @children.map(&:size).inject(&:+) || 0
    end

    def == other
      other.is_a?(self.class) && other.children == @children
    end
  end

  # An Expression that can be splatted into other nodes
  class TempExpression < Expression
    def to_a
      @children
    end
  end
end
