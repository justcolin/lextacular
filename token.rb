# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  # A leaf in the abstract syntax tree
  class Token
    def initialize content = ''
      @content = content
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
      other.is_a?(self.class) && other.to_s == @content
    end
  end
end
