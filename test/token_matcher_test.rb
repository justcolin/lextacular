# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require './mocks'
require '../token'
require '../matchers'

module Lextacular
  group TokenMatcher do
    group '#match' do
      pattern            = /hello/
      match_content      = 'hello'
      matching_string    = 'hello world'
      no_match_string    = 'goodbye for now'
      later_match_string = 'I say hello'
      starting_index     = 6

      matcher = TokenMatcher.new(pattern, Token)

      group 'given a string that starts with a match' do
        assert 'returns instance of the class given at initialization' do
          TokenMatcher.new(pattern, MockMatcherReturn)
                      .match(matching_string)
                      .is_a?(MockMatcherReturn) &&

          TokenMatcher.new(pattern, Token)
                      .match(matching_string)
                      .is_a?(Token)
        end

        assert 'return was given the matching string at initialization' do
          TokenMatcher.new(pattern, Token)
                      .match(matching_string)
                      .content
                      .==(match_content)
        end
      end

      assert 'given a string without a match, returns falsy' do
        !matcher.match(no_match_string)
      end

      group 'given a string with a match after the start' do
        assert 'returns falsy when not given a starting index' do
          !matcher.match(later_match_string)
        end

        assert 'returns falsy when given a wrong starting index' do
          !matcher.match(later_match_string, starting_index - 1)
        end

        assert 'returns match when given the starting index of the match' do
          matcher.match(later_match_string, starting_index)
        end
      end
    end
  end
end
