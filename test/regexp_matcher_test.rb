# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher_building'

module Lextacular
  module MatcherBuilding
    group '.regexp_matcher' do
      group 'given a matching string, returns match content' do
        matcher = regexp_matcher(/bubbles/)

        assert { matcher.call('bubbles are fun') == 'bubbles' }
      end

      group 'given a non-matching string, returns falsy' do
        matcher = regexp_matcher(/never found/)

        deny { matcher.call('something else') }
      end

      group 'given a string that matches later' do
        matcher     = regexp_matcher(/bloop/)
        later_match = 'blip bloop'
        match       = 'bloop'
        match_index = 5

        group 'returns falsy if index is not given' do
          deny { matcher.call(later_match) }
        end

        group 'returns falsy if index is wrong' do
          deny { matcher.call(later_match, match_index + 1) }
          deny { matcher.call(later_match, match_index - 1) }
        end

        group 'returns match if index is correct' do
          assert { matcher.call(later_match, match_index) == match }
        end
      end

      group 'returns falsy if the match is empty' do
        deny { regexp_matcher(//).call('content') }
      end
    end
  end
end
