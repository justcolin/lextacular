# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  module MatchMetadata
    attr_reader :name

    def without_temps
      unless @temp
        if respond_to? :map
          self.class.new(*map(&:without_temps).compact)
        else
          self
        end
      end
    end
  end
end
