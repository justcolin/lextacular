# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../build'

module Lextacular
  module Build
    group '.regexp_matcher' do
      assert 'given a matching string, returns match content' do
        matcher = regexp_matcher(/bubbles/)

        matcher.call('bubbles are fun') == 'bubbles'
      end

      assert 'given a non-matching string, returns falsy' do
        matcher = regexp_matcher(/never found/)

        !matcher.call('something else')
      end

      group 'given a string that matches later' do
        matcher     = regexp_matcher(/bloop/)
        later_match = 'blip bloop'
        match       = 'bloop'
        match_index = 5

        assert 'returns falsy if index is not given' do
          !matcher.call(later_match)
        end

        group 'returns falsy if index is wrong' do
          assert { !matcher.call(later_match, match_index + 1) }
          assert { !matcher.call(later_match, match_index - 1) }
        end

        assert 'returns match if index is correct' do
          matcher.call(later_match, match_index) == match
        end

        assert 'does not return matches from before the given index' do
          matcher     = regexp_matcher(/\d/)
          later_match = '42'
          match       = '2'
          match_index = 1

          matcher.call(later_match, match_index) == match
        end
      end

      assert 'returns falsy if the match is empty' do
        !regexp_matcher(//).call('content')
      end
    end
  end
end
