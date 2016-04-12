# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'
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
  group '.match_repeat' do
    group 'returns falsy if any children on the first pass return...' do
      with_falsy_and_mismatch do |option|
        yes = proc { 'truthy' }
        no  = proc { option }

        deny { match_repeat(no          ).call('') }
        deny { match_repeat(yes, no     ).call('') }
        deny { match_repeat(yes, no, yes).call('') }
      end
    end

    group 'keeps matching until one round returns...' do
      with_falsy_and_mismatch do |option|
        total_cycles = 3
        cycle_count  = 0
        match        = 'truthy'

        always_true      = proc { match }
        eventually_falsy = proc do
                             if cycle_count == total_cycles
                               option
                             else
                               cycle_count += 1
                               match
                             end
                           end

        assert do
          match_repeat(always_true, eventually_falsy, always_true)
                      .call('') == ([match] * total_cycles * 3)
        end
      end


      group 'a completely #empty? match' do
        total_cycles = 3
        cycle_count  = 0

        eventually_empty         = proc { '' }
        eventually_empty_counter = proc do
                                     if cycle_count == total_cycles
                                       ''
                                     else
                                       cycle_count += 1
                                       'a string'
                                     end
                                   end

        match_repeat(eventually_empty, eventually_empty_counter).call('')

        assert do
          cycle_count == total_cycles
        end
      end
    end

    group 'passes string and index into children, incrementing the index along the way' do
      total_cycles = 4
      cycle_count  = 0

      given_index  = rand
      given_string = rand.to_s

      result_indices = []
      result_strings = []

      pattern = [
                  proc do |string, index|
                    if cycle_count == total_cycles
                      nil
                    else
                      result_strings << string
                      result_indices << index

                      cycle_count += 1
                      "12"
                    end
                  end
                ]

      match_repeat(*pattern).call(given_string, given_index)

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
      match_repeat(proc { |_, index| result_index = index; nil })
                  .call('')


      assert { result_index == 0 }
    end
  end
end
