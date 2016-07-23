# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative '../with_falsy_and_mismatch'
require_relative '../mocks/mock_matcher'
require_relative '../mocks/mock_result'
require_relative '../../../counts'

def pattern_matcher_basics make_matcher, preserves_count: true
  group 'passes counts hash into children' do
    matcher = MockMatcher.new
    string  = 'yuppers'
    index   = 7
    counts  = Lextacular::Counts.new

    make_matcher.call(matcher)
                .call(string, index, counts: counts)

    assert { matcher.given?(string, index, counts) }
  end

  group 'if all children return matches' do
    assert 'return array of matches' do
      match_1 = "this"
      match_2 = "is a"
      match_3 = "match"

      result = make_matcher.call(
                             MockMatcher.new(match_1),
                             MockMatcher.new(match_2),
                             MockMatcher.new(match_3)
                           )
                           .call('', counts: Lextacular::Counts.new)

      result == [match_1, match_2, match_3]
    end

    assert 'flattens any array-like returns by parts of the matcher' do
      match_1 = "this"
      match_2 = "is a"
      match_3 = "match"

      result = make_matcher.call(
                             MockMatcher.new(match_1),
                             MockMatcher.new(MockArrayResult.new(match_2, match_3))
                           )
                           .call('', counts: Lextacular::Counts.new)

      result == [match_1, match_2, match_3]
    end

    if preserves_count
      assert 'lets children change the counts hash' do
        counts = Lextacular::Counts.new
        key    = :example_key
        value  = 56

        expected      = Lextacular::Counts.new
        expected[key] = value

        make_matcher.call(MockMatcher.new { |counts:| counts[key] = value })
                    .call('', counts: counts)

        counts == expected
      end
    end
  end

  group 'resets the counts hash if any children return' do
    with_falsy_and_mismatch do |falsy|
      counts          = Lextacular::Counts.new
      counts[:key]    = 10
      original_counts = counts.dup

      make_matcher.call(MockMatcher.new(falsy) { |counts:| counts[:anything] = 11 })
                  .call('', counts: counts)

      assert { counts == original_counts }
    end
  end

  group 'pass string and index into children, incrementing index as it goes' do
    index  = 10
    string = "this is not a pipe"
    counts = Lextacular::Counts.new

    first  = MockMatcher.new
    second = MockMatcher.new
    third  = MockMatcher.new

    make_matcher.call(first, second, third)
                .call(string, index, counts: Lextacular::Counts.new)

    assert {  first.given?(string, index, counts) }
    assert { second.given?(string, index + first.result_size, counts) }
    assert {  third.given?(string, index + first.result_size + second.result_size, counts) }
  end
end
