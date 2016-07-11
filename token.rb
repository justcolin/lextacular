# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details

require_relative './falsy'

module Lextacular
  # Wrapper around a string which was matched. Acts as a leaf in the parse tree.
  class Token
    include Falsy

    attr_reader :content, :name, :temp

    def initialize content = '', name: nil, temp: nil
      @content = content
      @name    = name
      @temp    = temp
    end

    def to_s
      @content
    end

    def size
      @content.size
    end

    def empty?
      size.zero?
    end

    def == other
      other.is_a?(self.class) &&
      other.content == @content &&
      falsy_or_equal?(other.name, @name) &&
      falsy_or_equal?(other.temp, @temp)
    end

    # Returns nil if this Token is marked as temporary, else returns self.
    def without_temps
      self unless @temp
    end
  end
end
