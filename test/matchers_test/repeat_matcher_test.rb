# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../matchers'
require_relative '../../expression'
require_relative '../../mismatch'
require_relative '../helpers/with_falsy_and_mismatch.rb'

module Lextacular
  module Matchers
    group '.repeat_matcher' do
      group 'returns falsy if children immediately return...' do
        with_falsy_and_mismatch do |value|
          match = proc { 'truthy' }
          none  = proc { value }

          assert { !repeat_matcher(none              ).call('') }
          assert { !repeat_matcher(match, none       ).call('') }
          assert { !repeat_matcher(match, none, match).call('') }
        end
      end

      group 'keeps matching until an item returns...' do
        assert 'a completely #empty? match' do
          total_cycles = 3
          cycle_count  = 0

          empty            = proc { '' }
          eventually_empty = proc do
                               if cycle_count == total_cycles
                                 ''
                               else
                                 cycle_count += 1
                                 'a string'
                               end
                             end

          repeat_matcher(empty, eventually_empty, empty).call('')

          cycle_count == total_cycles
        end

        with_falsy_and_mismatch do |value|
          total_cycles = 3
          cycle_count  = 0
          match        = 'truthy'

          always_true      = proc { match }
          eventually_falsy = proc do
                               if cycle_count == total_cycles
                                 value
                               else
                                 cycle_count += 1
                                 match
                               end
                             end

          assert do
            repeat_matcher(always_true, eventually_falsy, always_true)
                          .call('') == ([match] * total_cycles * 3)
          end
        end
      end

      assert 'resets counts hash if any part of the pattern does not match' do
        original_hash = { x: 1, y: 2 }
        counts_hash   = original_hash.dup

        repeat_matcher(
                        proc do |counts:|
                          counts.clear
                          'a match'
                        end,
                        proc { nil }
                      )
                      .call('', counts: counts_hash)

        counts_hash == original_hash
      end

      assert 'resets the counts hash back to the value from the last full match' do
        counts_hash  = { iteration: 0 }
        total_cycles = 4

        repeat_matcher(
                        proc do |counts:|
                          counts[:iteration] += 1
                          'a match'
                        end,
                        proc do |counts:|
                          'a match' unless counts[:iteration] == total_cycles
                        end
                      )
                      .call('', counts: counts_hash)

        counts_hash[:iteration] == total_cycles - 1
      end

      group 'passes string and index into children, incrementing the index along the way' do
        total_cycles = 4
        cycle_count  = 0

        given_index  = 7727
        given_string = 'the prerogative to have a little fun'

        result_indices = []
        result_strings = []

        pattern = proc do |string, index|
                    if cycle_count == total_cycles
                      nil
                    else
                      result_strings << string
                      result_indices << index

                      cycle_count += 1
                      "12"
                    end
                  end

        repeat_matcher(pattern).call(given_string, given_index)

        assert { result_strings == ([given_string] * total_cycles) }
        assert do
          result_indices == [
                              given_index,     given_index + 2,
                              given_index + 4, given_index + 6,
                            ]
        end
      end
    end
  end
end
