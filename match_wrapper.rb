# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './mismatch'
require_relative './falsy'

module Lextacular
  class MatchWrapper
    include Falsy

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
      other.is_a?(MatchWrapper) &&
      falsy_or_equal?(other.given_class, @given_class) &&
      falsy_or_equal?(other.matcher,     @matcher) &&
      falsy_or_equal?(other.name,        @name) &&
      falsy_or_equal?(other.temp,        @temp) &&
      falsy_or_equal?(other.defs,        @defs)
    end
  end
end
