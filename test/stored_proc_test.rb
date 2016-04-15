# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require '../matcher_building'

module Lextacular
  module MatcherBuilding
    group '.stored_proc' do
      group 'returns a function which...' do
        group 'calls the function stored in the hash' do
          called = false
          hash   = { example: proc { called = true } }

          stored_proc(hash, :example).call

          assert { called }
        end

        group 'returns whatever the stored function returns' do
          result = 'fluffle bumble'
          hash   = { the_name: proc { result } }

          assert { stored_proc(hash, :the_name).call == result }
        end

        group 'stored function can be added after creating the stored_proc' do
          hash   = {}
          stored = stored_proc(hash, :sally)

          called       = false
          hash[:sally] = proc { called = true }

          stored.call

          assert { called }
        end

        group 'passes arguments to the stored function' do
          args = [1, 'two', :iii]
          hash = { funky_func: proc { |*args| args } }

          assert { stored_proc(hash, :funky_func).call(*args) == args }
        end
      end
    end
  end
end
