# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  module RecursiveFlatten
    refine Array do
      def recursive_flatten
        self.map do |item|
              if item.respond_to?(:to_a)
                item.to_a.recursive_flatten
              else
                item
              end
            end
            .flatten
      end
    end
  end
end
