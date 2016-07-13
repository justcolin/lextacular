# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  # Create a reference to a matcher that may not exist at the time this object
  # was initialized.
  class FutureWrapper
    # Take a key and hash where the matcher can eventually be fetched, and
    # optionally take a rename value and a Proc to extend the result.
    def initialize key, hash, defs: nil, new_name: nil
      @key      = key
      @hash     = hash
      @defs     = defs
      @new_name = new_name
    end

    # Create a new Future wrapper with all the same values but change the name.
    def rename new_name
      self.class.new(@key, @hash, defs: @defs, new_name: new_name)
    end

    # Fetch the matcher, call it, then extend the result.
    def call string, index = 0, counts: {}
      unless @matcher
        @matcher = @hash.fetch(@key)
        @matcher = @matcher.rename(@new_name) if @new_name
      end

      @matcher.call(string, index, counts: counts)
              .tap do |result|
                result.singleton_class.class_eval(&@defs) if @defs
              end
    end
  end
end
