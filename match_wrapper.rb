# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './mismatch'

module Lextacular
  class MatchWrapper
    attr_reader :given_class, :wrap_class, :matcher, :name, :temp, :defs

    def initialize wrap_class, matcher, name: nil, temp: nil, defs: nil
      @given_class = wrap_class
      @wrap_class  = defs ? Class.new(wrap_class, &defs) : wrap_class
      @matcher     = matcher
      @name        = name
      @temp        = temp
      @defs        = defs
    end

    def rename new_name
      self.class.new(
        @given_class,
        @matcher,
        name: new_name,
        temp: @temp,
        defs: defs
      )
    end

    def call string, index = 0
      found = @matcher.call(string, index)

      if found.is_a?(Mismatch)
        found
      elsif found
        @wrap_class.new(*found, name: @name, temp: @temp)
      else
        Mismatch.new(string, index)
      end
    end

    def == other
      other.is_a?(MatchWrapper)         &&
      other.given_class == @given_class &&
      other.matcher     == @matcher     &&
      other.name        == @name        &&
      other.temp        == @temp        &&
      other.defs        == @defs
    end
  end
end
