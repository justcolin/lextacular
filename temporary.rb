# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './decorator'

module Lextacular
  class Temporary < Decorator
    def initialize wrapped, temp = true
      super wrapped
      @temp = temp
    end

    def temp?
      @temp
    end
  end
end
