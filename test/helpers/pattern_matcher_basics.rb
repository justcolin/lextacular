# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './with_falsy_and_mismatch'
require_relative '../../counts'

def pattern_matcher_basics make_matcher, preserves_count: true
  group 'passes counts hash into children' do
    counts_hash  = Lextacular::Counts.new
    given_string = 'yuppers'
    given_index  = 7

    result_string = nil
    result_index  = nil
    result_counts = nil

    checker = proc do |string, index, counts:|
                result_string = string
                result_index  = index
                result_counts = counts
                'something'
              end

    make_matcher.call(checker)
                .call(given_string, given_index, counts: counts_hash)

    assert { result_string == given_string }
    assert { result_index  == given_index }
    assert { result_counts == counts_hash }
  end

  group 'if all children return matches' do
    assert 'return array of matches' do
      match_1 = "this"
      match_2 = "is a"
      match_3 = "match"

      make_matcher.call(
                    proc { match_1 },
                    proc { match_2 },
                    proc { match_3 }
                  )
                  .call('', counts: Lextacular::Counts.new)
                  .==([match_1, match_2, match_3])
    end

    assert 'flattens any arrays returns by parts of the matcher' do
      match_1 = "this"
      match_2 = "is a"
      match_3 = "match"

      make_matcher.call(
                    proc { match_1 },
                    proc { [match_2, match_3] }
                  )
                  .call('', counts: Lextacular::Counts.new)
                  .==([match_1, match_2, match_3])
    end

    if preserves_count
      assert 'lets children change the counts hash' do
        counts_hash = Lextacular::Counts.new
        expected    = Lextacular::Counts.new
        key         = :example_key
        value       = 56

        expected[key] = value

        make_matcher.call(
                      proc do |counts:|
                        counts[key] = value
                        'something'
                      end
                    )
                    .call('', counts: counts_hash)

        counts_hash == expected
      end
    end
  end

  group 'resets the counts hash if any children return' do
    with_falsy_and_mismatch do |value|
      assert do
        counts_hash     = Lextacular::Counts.new
        original_values = counts_hash.dup

        make_matcher.call(
                      proc do |counts:|
                        counts[:anything] = 11
                        value
                      end
                    )
                    .call('', counts: counts_hash)

        counts_hash == original_values
      end
    end
  end

  group 'pass string and index into children, incrementing index as it goes' do
    given_index  = 10
    given_string = "this is not a pipe"

    match_1 = "12345678"
    match_2 = "123"
    match_3 = "something else"

    result_indices = []
    result_strings = []

    pattern = [
                proc do |string, index|
                  result_strings << string
                  result_indices << index

                  match_1
                end,
                proc do |string, index|
                  result_strings << string
                  result_indices << index

                  match_2
                end,
                proc do |string, index|
                  result_strings << string
                  result_indices << index

                  match_3
                end
              ]

    make_matcher.call(*pattern)
                .call(given_string, given_index, counts: Lextacular::Counts.new)

    assert { result_strings == [given_string] * 3 }
    assert do
      result_indices == [
                          given_index,
                          given_index + match_1.size,
                          given_index + match_1.size + match_2.size
                        ]
    end
  end
end
