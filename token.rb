# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  # A leaf in the abstract syntax tree
  class Token
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
      other.to_s == @content  &&
      other.name == @name     &&
      other.temp == @temp
    end

    def without_temps
      self unless @temp
    end
  end
end
