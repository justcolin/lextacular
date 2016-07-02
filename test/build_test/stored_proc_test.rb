# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require '../build'

module Lextacular
  module Build
    group '.stored_proc' do
      group 'returns a function which...' do
        assert 'calls the function stored in the hash' do
          was_called = false
          hash       = { example: proc { was_called = true } }

          stored_proc(:example, hash).call

          was_called
        end

        assert 'returns whatever the stored function returns' do
          result = 'fluffle bumble'
          hash   = { the_name: proc { result } }

          stored_proc(:the_name, hash).call == result
        end

        assert 'stored function can be added after creating the stored_proc' do
          hash   = {}
          stored = stored_proc(:sally, hash)

          was_called   = false
          hash[:sally] = proc { was_called = true }

          stored.call

          was_called
        end

        assert 'passes arguments to the stored function' do
          args = [1, 'two', :iii]
          hash = { funky_func: proc { |*args| args } }

          stored_proc(:funky_func, hash).call(*args) == args
        end

        group 'errors properly if function is not defined at call time' do
          stored = stored_proc(:never_defined, {})
          err(expect: KeyError) { stored.call }
        end
      end
    end
  end
end
