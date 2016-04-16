# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

def pattern_matcher_like make_matcher
  group 'return array of matches if all children return matches' do
    assert do
      match_1 = "this"
      match_2 = "is a"
      match_3 = "match"

      make_matcher.call(
                    proc { match_1 },
                    proc { match_2 },
                    proc { match_3 }
                  )
                  .call('') == [match_1, match_2, match_3]
    end
  end

  group 'pass string and index into children, incrementing index as it goes' do
    given_index  = 10
    given_string = "this is not a pipe"

    result_indices = []
    result_strings = []

    pattern = [
                proc do |string, index|
                  result_strings << string
                  result_indices << index

                  "12345678"
                end,
                proc do |string, index|
                  result_strings << string
                  result_indices << index

                  "123"
                end,
                proc do |string, index|
                  result_strings << string
                  result_indices << index

                  "something else"
                end
              ]

    make_matcher.call(*pattern).call(given_string, given_index)

    assert { result_strings == [given_string] * 3 }
    assert { result_indices == [given_index, given_index + 8, given_index + 11] }
  end

  group 'index defaults to 0' do
    result_index = nil
    index_proc   = proc do |_, index|
                     result_index = index
                     'stringy stringle string'
                   end

    make_matcher.call(index_proc).call('')

    assert { result_index.zero? }
  end
end
