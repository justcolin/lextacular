# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../build'
require_relative '../mismatch'

module Lextacular
  module Build
    group '.either_matcher' do
      group 'returns falsy if all children return falsy, #empty? matches or Mismatches' do
        assert do
          !either_matcher(
            proc { '' },
            proc { [] },
            proc { nil },
            proc { false },
            proc { Mismatch.new }
          ).call('')
        end
      end

      group 'returns the first match if any child matches' do
        first_match  = 'Oooooo, Ford Focus'
        second_match = 'The example above is an obscure song reference'

        no    = proc { nil }
        yes_1 = proc { first_match }
        yes_2 = proc { second_match }

        assert { either_matcher(yes_1           ).call('') == first_match }
        assert { either_matcher(yes_1, yes_2    ).call('') == first_match }
        assert { either_matcher(no, yes_1, yes_2).call('') == first_match }
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

        either_matcher(*pattern).call(given_string, given_index)

        assert { result_strings == [given_string, given_string] }
        assert { result_indices == [given_index,  given_index ] }
      end

      group 'index defaults to 0' do
        result     = nil
        index_proc = proc { |_, index| result = index; '' }

        either_matcher(index_proc).call('')

        assert { result.zero? }
      end
    end
  end
end
