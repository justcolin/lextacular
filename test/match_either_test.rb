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

    group 'passes string and index into children' do
      given_index  = rand
      given_string = rand.to_s

      result_index_1  = nil
      result_index_2  = nil
      result_string_2 = nil
      result_string_1 = nil

      pattern = [
                  proc do |string, index|
                    result_string_1 = string
                    result_index_1  = index

                    false
                  end,
                  proc do |string, index|
                    result_string_2 = string
                    result_index_2  = index
                  end
                ]

      match_either(*pattern).call(given_string, given_index)

      assert { result_string_1 == given_string }
      assert { result_string_2 == given_string }

      assert { result_index_1 == given_index }
      assert { result_index_2 == given_index }
    end

    group 'index defaults to 0' do
      result_index = nil
      index_proc   = proc { |_, index| result_index = index }

      match_either(index_proc).call('')

      assert { result_index.zero? }
    end
  end
end
