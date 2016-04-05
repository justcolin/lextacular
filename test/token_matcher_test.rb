# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require '../token'
require '../matchers'

module Lextacular
  group TokenMatcher do
    group '#match' do
      match_content      = 'hello'
      matching_string    = 'hello world'
      no_match_string    = 'goodbye for now'
      later_match_string = 'I say hello'
      matcher            = TokenMatcher.new(/#{match_content}/, String)

      group 'given a string that starts with a match' do
        given_string = TokenMatcher.new(/#{match_content}/, String)
        given_token  = TokenMatcher.new(/#{match_content}/, Token)

        assert 'returns instance of the class given at initialization' do
          given_string.match(matching_string).is_a?(String) &&
          given_token.match(matching_string).is_a?(Token)
        end

        assert 'return was given the matching string at initialization' do
          given_string.match(matching_string).to_s == match_content &&
          given_token.match(matching_string).to_s == match_content
        end
      end

      assert 'given a string without a match, returns falsy' do
        !matcher.match(no_match_string)
      end

      assert 'given a string with a match after the start, returns falsy' do
        !matcher.match(later_match_string)
      end
    end
  end
end
