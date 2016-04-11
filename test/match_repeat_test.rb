# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'
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
    group 'returns falsy if any children return' do
      with_falsy_and_mismatch do |option|
        yes = proc { 'truthy' }
        no  = proc { option }

        deny { match_repeat(no          ).call('') }
        deny { match_repeat(yes, no     ).call('') }
        deny { match_repeat(yes, no, yes).call('') }
      end
    end

    group 'returns array of matches until a pattern returns...' do
      with_falsy_and_mismatch do |option|
        total_cycles = 3
        cycle_count  = 0
        match        = 'truthy'

        always_true      = proc { match }
        eventually_falsy = lambda do |_, _ = 0|
                             if cycle_count == total_cycles
                               return option
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
    end
  end
end
