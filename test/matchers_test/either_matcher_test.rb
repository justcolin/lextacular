# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../matchers'
require_relative '../../mismatch'

module Lextacular
  module Matchers
    group '.either_matcher' do
      assert 'returns falsy if all children return falsy or Mismatches' do
        !either_matcher(
          proc { nil },
          proc { false },
          proc { Mismatch.new }
        ).call('', counts: {})
      end

      group 'returns the first match if any child matches' do
        first_match  = 'Oooooo, Ford Focus'
        second_match = 'The example above is an obscure song reference'

        no    = proc { nil }
        yes_1 = proc { first_match }
        yes_2 = proc { second_match }

        assert { either_matcher(yes_1           ).call('', counts: {}) == first_match }
        assert { either_matcher(yes_1, yes_2    ).call('', counts: {}) == first_match }
        assert { either_matcher(no, yes_1, yes_2).call('', counts: {}) == first_match }
      end

      group 'resets the counts hash if there are no matchers' do
        original_hash = { x:1, y: 2 }
        counts_hash   = original_hash.dup
        given_counts  = nil
        checker       = proc do |counts:|
                          given_counts = counts
                          counts.clear
                          false
                        end

        either_matcher(checker, checker).call('', counts: counts_hash)

        assert { given_counts == original_hash }
        assert { counts_hash  == original_hash }
      end

      group 'passes string and index into children' do
        given_index  = 999
        given_string = 'Forsooth!'

        result_indices = []
        result_strings = []

        pattern = [
                    proc do |string, index|
                      result_strings << string
                      result_indices << index

                      false
                    end,
                    proc do |string, index|
                      result_strings << string
                      result_indices << index
                    end
                  ]

        either_matcher(*pattern).call(given_string, given_index, counts: {})

        assert { result_strings == [given_string, given_string] }
        assert { result_indices == [given_index,  given_index ] }
      end
    end
  end
end
