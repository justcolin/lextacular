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
      assert '#pop_context removes all counts if #push_context not called before' do
        example      = Counts.new
        key          = :skeleton
        value        = 72
        example[key] = value

        example.pop_context

        example[key] < 0
      end

      assert '#pop_context resets to state before last #push_context' do
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

        example[key] == prev_value
      end

      assert 'resets values to be less than zero if they were only set after #push_context' do
        example        = Counts.new
        key            = :set_midway

        example.push_context

        example[key] = 94

        example.pop_context

        example[key] < 0
      end

      assert 'values can be recovered from before #push_context' do
        example      = Counts.new
        key          = :set_before_push
        prev_value   = 6
        example[key] = prev_value

        example.push_context

        example[key] == prev_value
      end
    end

    group '#replace' do
      assert 'returns self' do
        example = Counts.new

        example.replace(Counts.new) == example
      end

      group 'replaces content with content of other Counts object' do
        example   = Counts.new
        other     = Counts.new
        key       = :an_example_key
        other_key = :another_example_key
        new_value = 46

        example[key]       = new_value + 1
        example[other_key] = new_value + 2
        other[key]         = new_value

        example.replace(other)

        assert { example[key] == new_value }
        assert { example[other_key] < 0 }
      end
    end

    group '#==' do
      assert 'returns true if values are the same' do
        example_1 = Counts.new
        example_2 = Counts.new

        [example_1, example_2].each do |example|
          example[:key]         = 39
          example[:another_key] = 100
        end

        example_1 == example_2
      end

      assert 'returns false if values are not the same' do
        example_1 = Counts.new
        example_2 = Counts.new
        key       = :this_is_a_key

        [example_1, example_2].each do |example|
          example[key]          = 624
          example[:another_key] = 232
        end

        example_1[key] += 1

        example_1 != example_2
      end
    end

    group '#dup' do
      assert 'returns an object with the same content' do
        example             = Counts.new
        example[:something] = 2034

        example.dup == example
      end

      assert 'does not return self' do
        example = Counts.new

        !example.dup.equal?(example)
      end

      group 'editing the duped copy does not effect the original' do
        key       = :something_something
        old_value = 3
        new_value = old_value + 1

        example      = Counts.new
        example[key] = old_value

        duped      = example.dup
        duped[key] = new_value


        assert { example      != old_value }
        assert { example[key] == old_value }
        assert { duped[key]   == new_value }
      end
    end
  end
end
