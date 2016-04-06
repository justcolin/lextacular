# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  module MatcherInit
    def initialize pattern, klass
      @pattern = pattern
      @klass   = klass
    end
  end

  class TokenMatcher
    include MatcherInit

    def match string, start_index = 0
      found = string.match(@pattern, start_index)

      @klass.new(found.to_s) if found && found.begin(0) == start_index
    end
  end

  class ExpressionMatcher
    include MatcherInit

    def match string, start_index = 0
      matches = @pattern.inject([]) do |memo, part|
                  if memo
                    found = part.match(string, start_index)

                    if found
                      start_index += found.size
                      memo << found
                    end
                  else
                    break
                  end
                end


      @klass.new(*matches) if matches
    end
  end
end
