# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../build'
require_relative '../expression'
require_relative '../mismatch'

def with_falsy_and_mismatch
  group 'falsy' do
    yield nil
  end

  group 'a Mismatch' do
    yield Lextacular::Mismatch.new
  end
end

module Lextacular
  module Build
    group '.repeat_matcher' do
      group 'returns falsy if children immediately return...' do
        with_falsy_and_mismatch do |stop|
          yes = proc { 'truthy' }
          no  = proc { stop }

          assert { !repeat_matcher(no          ).call('') }
          assert { !repeat_matcher(yes, no     ).call('') }
          assert { !repeat_matcher(yes, no, yes).call('') }
        end
      end

      group 'keeps matching until an item returns...' do
        group 'a completely #empty? match' do
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

          assert { cycle_count == total_cycles }
        end

        with_falsy_and_mismatch do |stop|
          total_cycles = 3
          cycle_count  = 0
          match        = 'truthy'

          always_true      = proc { match }
          eventually_falsy = proc do
                               if cycle_count == total_cycles
                                 stop
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

      group 'index defaults to 0' do
        result_index = nil
        repeat_matcher(proc { |_, index| result_index = index; nil })
                    .call('')


        assert { result_index == 0 }
      end
    end
  end
end
