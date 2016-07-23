# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './matchers'

module Lextacular
  # Create a reference to a matcher that may not exist at the time this object
  # was initialized.
  class FutureWrapper
    # Takes a +key+ which will be used to lookup a matcher from the +hash+ when
    # called. Optionally takes the named arguments +defs+, which takes a proc
    # used to extend whatever matches are returned, and +name+, which is used to
    # rename the results from the matcher.
    def initialize key, hash, defs: nil, name: nil
      @key  = key
      @hash = hash
      @defs = defs
      @name = name
    end

    # Create a new Future wrapper with all the same values but changes the name.
    def rename new_name
      self.class.new(@key, @hash, defs: @defs, name: new_name)
    end

    # Fetch the matcher, call it passing in a +string+ and optionally an +index+
    # and +counts+ hash.
    def call string, index = 0, counts:
      unless @matcher
        @matcher = @hash.fetch(@key)
        @matcher = @matcher.rename(@name) if @name
      end

      @matcher.call(string, index, counts: counts)
              .tap do |result|
                if @defs && Matchers.match?(result)
                  result.singleton_class.class_eval(&@defs)
                end
              end
    end
  end
end
