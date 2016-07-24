# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../matchers'
require_relative '../../counts'
require_relative '../helpers/with_falsy_and_mismatch.rb'
require_relative '../helpers/mocks/mock_matcher.rb'

module Lextacular
  module Matchers
    group '.repeat_matcher' do
      group 'returns falsy if children immediately returns' do
        with_falsy_and_mismatch do |falsy|
          yes = MockMatcher.new('truthy')
          no  = MockMatcher.new(falsy)

          assert { !repeat_matcher(no          ).call('', counts: Counts.new) }
          assert { !repeat_matcher(yes, no     ).call('', counts: Counts.new) }
          assert { !repeat_matcher(yes, no, yes).call('', counts: Counts.new) }
        end
      end

      group 'keeps matching until an item returns' do
        assert 'a completely #empty? match' do
          total_cycles = 3
          cycle_count  = 0

          empty            = MockMatcher.new('')
          eventually_empty = proc do
                               if cycle_count == total_cycles
                                 ''
                               else
                                 cycle_count += 1
                                 'a string'
                               end
                             end

          repeat_matcher(empty, eventually_empty, empty).call('', counts: Counts.new)

          cycle_count == total_cycles
        end

        with_falsy_and_mismatch do |value|
          total_cycles = 3
          cycle_count  = 0

          always_match        = MockMatcher.new
          eventually_mismatch = proc do
                                  if cycle_count == total_cycles
                                    value
                                  else
                                    cycle_count += 1
                                    always_match.result
                                  end
                                end

          result = repeat_matcher(always_match, eventually_mismatch, always_match)
                                 .call('', counts: Counts.new)

          assert { result == [always_match.result] * total_cycles * 3 }
        end
      end

      assert 'resets counts hash if any part of the pattern does not match' do
        counts           = Counts.new
        counts[:yuppers] = 25
        original_counts  = counts.dup

        repeat_matcher(
                        MockMatcher.new { |counts:| counts.replace(Counts.new) },
                        MockMatcher.new(nil)
                      )
                      .call('', counts: counts)

        counts == original_counts
      end

      assert 'resets the counts hash back to the value from the last full match' do
        counts          = Counts.new
        counts[:cycles] = 0
        total_cycles    = 4

        repeat_matcher(
                        MockMatcher.new { |counts:| counts[:cycles] += 1 },
                        proc do |counts:|
                          'a match' unless counts[:cycles] == total_cycles
                        end
                      )
                      .call('', counts: counts)

        counts[:cycles] == total_cycles - 1
      end

      group 'passes string and index into children, incrementing the index along the way' do
        total_cycles = 4
        cycle_count  = 0

        index  = 7727
        string = 'the prerogative to have a little fun'

        result_indices = []
        result_strings = []

        pattern = proc do |string, index|
                    if cycle_count == total_cycles
                      nil
                    else
                      result_strings << string
                      result_indices << index

                      cycle_count += 1
                      string
                    end
                  end

        repeat_matcher(pattern).call(string, index, counts: Counts.new)

        assert { result_strings == ([string] * total_cycles) }
        assert do
          result_indices == [
                              index,                   index + string.size,
                              index + string.size * 2, index + string.size * 3,
                            ]
        end
      end
    end
  end
end
