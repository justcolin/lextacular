# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  class TokenMatcher
    def initialize pattern, klass
      @pattern = pattern
      @klass   = klass
    end

    def match string
      found = string.match(@pattern)

      @klass.new(found.to_s) if found && found.begin(0).zero?
    end
  end
end
