# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'
require_relative '../mismatch'

module Lextacular
  group '.match_either' do
    group 'returns falsy if all children return falsy or Mismatches' do
      deny do
        match_either(
          proc { nil },
          proc { false },
          proc { Mismatch.new }
        ).call('')
      end
    end

    group 'returns the first match if any child matches' do
      first_match  = rand.to_s
      second_match = first_match + rand.to_s

      no    = proc { nil }
      yes_1 = proc { first_match }
      yes_2 = proc { second_match }

      assert { match_either(yes_1           ).call('') == first_match }
      assert { match_either(yes_1, yes_2    ).call('') == first_match }
      assert { match_either(no, yes_1, yes_2).call('') == first_match }
    end
  end
end
