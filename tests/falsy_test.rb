# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../falsy'

module Lextacular
  group Falsy do
    module ExampleWithFalsy
     extend Falsy

      group '#falsy_or_equal?' do
        group 'returns true' do
          assert 'when given two equal object' do
            falsy_or_equal? 1.0, 1
          end

          assert 'if given nil and false' do
            falsy_or_equal? nil, false
          end
        end

        assert 'returns false if given two unequal objects' do
          !falsy_or_equal? "something", "something else"
        end
      end
    end
  end
end
