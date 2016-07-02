# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './decorator'

module Lextacular
  class Tempable < Decorator
    def initialize wrapped, temp = true
      super wrapped
      @temp = temp
    end

    def without_temps
      unless @temp
        if respond_to? :map
          @object.class.new(*map(&:without_temps).compact)
        else
          @object
        end
      end
    end
  end
end
