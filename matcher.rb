# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  module_function

  def build_matcher klass, pattern_matcher
    proc do |string, index|
      found = pattern_matcher.call(string, index)

      if found
        klass.new(*found)
      else
        Mismatch.new(string, index)
      end
    end
  end
end
