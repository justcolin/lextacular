# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './falsy'

module Lextacular
  # Wrapper around multiple ordered Tokens and Expressions
  class Expression
    include Enumerable
    include Falsy

    undef_method :to_a rescue NameError

    attr_reader :children, :name, :temp

    def initialize *children, name: nil, temp: nil
      @children = children
      @name     = name
      @temp     = temp
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
      other.is_a?(self.class) &&
      other.children == @children &&
      falsy_or_equal?(other.temp, @temp) &&
      falsy_or_equal?(other.name, @name)
    end

    def each &block
      return enum_for :each unless block_given?

      @children.each(&block)

      self
    end

    # Return a new Expression, removing all children marked as temporary. Return
    # nil if this Expression is marked as temporary.
    def without_temps
      unless @temp
        self.class.new(
          *@children.map { |part| part.without_temps }.compact,
          name: @name,
          temp: @temp
        )
      end
    end
  end

  # An Expression that can be splatted.
  class SplatExpression < Expression
    def to_a
      @children
    end
  end
end
