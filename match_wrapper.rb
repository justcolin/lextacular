# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './mismatch'
require_relative './falsy'

module Lextacular
  # Wraps the output of a matcher whenever it is called.
  class MatchWrapper
    include Falsy

    attr_reader :given_class, :wrap_class, :matcher, :name, :temp, :defs

    # Takes the return class, matcher and optionally takes a name for the
    # output, whether or not it should be marked as temporary, and a Proc to
    # extend the given class with.
    def initialize wrap_class, matcher, name: nil, temp: nil, defs: nil
      @given_class = wrap_class
      @wrap_class  = defs ? Class.new(wrap_class, &defs) : wrap_class
      @matcher     = matcher
      @name        = name
      @temp        = temp
      @defs        = defs
    end

    # Create a new MatchWrapper with all the same values but change the name.
    def rename new_name
      self.class.new(
        @given_class,
        @matcher,
        name: new_name,
        temp: @temp,
        defs: defs
      )
    end

    # Call the matcher. If there is a match, return an instance of the given
    # class. If is no match, make sure a Mismatch is returned.
    def call string, index = 0, counts: {}
      found = @matcher.call(string, index, counts: counts)

      if found.is_a?(Mismatch)
        found
      elsif found
        @wrap_class.new(*found, name: @name, temp: @temp)
      else
        Mismatch.new(string, index)
      end
    end

    # MatchWrappers are equal if all their instance variables are the same.
    def == other
      other.is_a?(MatchWrapper) &&
      other.given_class == @given_class &&
      other.matcher == @matcher &&
      falsy_or_equal?(other.name, @name) &&
      falsy_or_equal?(other.temp, @temp) &&
      falsy_or_equal?(other.defs, @defs)
    end
  end
end
