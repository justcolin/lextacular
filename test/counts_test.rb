# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../counts'

module Lextacular
  group Counts do
    assert 'an unset count is less than zero' do
      Counts.new[:this_was_not_set] < 0
    end

    group '#[] and #[]=' do
      group 'can set/fetch multiple keys' do
        example = Counts.new

        key_1   = :here_is_a_key
        key_2   = :here_is_another_key
        value_1 = 81
        value_2 = 73

        example[key_1] = value_1
        example[key_2] = value_2

        assert { example[key_1] == value_1 }
        assert { example[key_2] == value_2 }
      end
    end

    group '#push_context and #pop_context' do
      group '#pop_context removes all counts if #push_context not called before' do
        example      = Counts.new
        key          = :skeleton
        value        = 72
        example[key] = value

        example.pop_context

        assert { example[key] < 0 }
      end

      group '#pop_context resets to state before last #push_context' do
        example      = Counts.new
        key          = :under_test
        prev_value   = 45
        example[key] = prev_value

        example.push_context

        # Make sure the value can be reset multiple times between #push_context
        # and #pop_context.
        example[key] = prev_value + 1
        example[key] = prev_value + 2

        example.pop_context

        assert { example[key] == prev_value }
      end

      group 'resets values to be less than zero if they were only set after #push_context' do
        example        = Counts.new
        key            = :set_midway

        example.push_context

        example[key] = 94

        example.pop_context

        assert { example[key] < 0 }
      end

      group 'values can be recovered from before #push_context' do
        example      = Counts.new
        key          = :set_before_push
        prev_value   = 6
        example[key] = prev_value

        example.push_context

        assert { example[key] == prev_value }
      end
    end
  end
end
