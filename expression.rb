# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  # Wrapper around multiple ordered Tokens and Expression
  class Expression
    include Enumerable

    attr_reader :children

    def initialize *children
      @children = children
    end

    def to_s
      @children.map(&:to_s).join
    end

    def size
      @children.map(&:size).inject(&:+) || 0
    end

    def empty?
      size.zero?
    end

    def == other
      other.is_a?(self.class) && other.children == @children
    end

    def each &block
      return enum_for :each unless block_given?

      @children.each(&block)

      self
    end

    undef_method :to_a rescue NameError
  end

  # An Expression that can be splatted into other nodes
  class SplatExpression < Expression
    def to_a
      @children
    end
  end
end
