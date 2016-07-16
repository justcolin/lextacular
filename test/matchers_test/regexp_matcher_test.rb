# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../matchers'

module Lextacular
  module Matchers
    group '.regexp_matcher' do
      group 'given a matching string' do
        matcher   = regexp_matcher(/bubbles/)
        has_match = 'bubbles are fun'
        match     = 'bubbles'

        assert 'returns match content' do
          matcher.call(has_match, counts: {}) == match
        end

        assert 'does not effect the counts hash' do
          counts_hash   = { x: 1, y: 2 }
          original_hash = counts_hash.dup
          matcher.call(has_match, counts: counts_hash)

          counts_hash == original_hash
        end
      end

      group 'given a non-matching string' do
        matcher  = regexp_matcher(/never found/)
        no_match = 'something else'

        assert 'returns falsy' do
          !matcher.call(no_match, counts: {})
        end

        assert 'does not effect the counts hash' do
          counts_hash = { x: 1, y: 2 }
          original_hash = counts_hash.dup
          matcher.call(no_match, counts: counts_hash)

          counts_hash == original_hash
        end
      end

      group 'given a string that matches later' do
        matcher     = regexp_matcher(/bloop/)
        later_match = 'blip bloop'
        match       = 'bloop'
        match_index = 5

        assert 'returns falsy if index is not given' do
          !matcher.call(later_match, counts: {})
        end

        group 'returns falsy if index is wrong' do
          assert { !matcher.call(later_match, match_index + 1, counts: {}) }
          assert { !matcher.call(later_match, match_index - 1, counts: {}) }
        end

        assert 'returns match if index is correct' do
          matcher.call(later_match, match_index, counts: {}) == match
        end

        assert 'does not return matches from before the given index' do
          matcher     = regexp_matcher(/\d/)
          later_match = '42'
          match       = '2'
          match_index = 1

          matcher.call(later_match, match_index, counts: {}) == match
        end
      end

      assert 'returns falsy if the match is empty' do
        !regexp_matcher(//).call('content', counts: {})
      end
    end
  end
end
