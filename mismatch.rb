# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  # Error raised when a mismatch occurs
  class Mismatch < StandardError
    attr_reader :content, :index

    def initialize(content = nil, index = nil)
      @content = content
      @index   = index
    end

    def message
      "match not found at this index: #{@index}"
    end
  end
end
