# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative './mocks'
require_relative '../token'
require_relative '../expression'
require_relative '../matchers'

module Lextacular
  group EitherMatcher do
    group '#match' do
      word    = TokenMatcher.new(/\w+/, Token)
      space   = TokenMatcher.new(/ /, Token)
      matcher = EitherMatcher.new(
                  TokenMatcher.new(/frantic/, Token),
                  TokenMatcher.new(/fran/, Token),
                  ExpressionMatcher.new([word, space, word], Expression)
                )

      no_match        = ':-('

      has_later_match = ':-( frantic'
      later_match     = Token.new('frantic')
      starting_index  = 4

      has_match_1     = 'frantic follies'
      match_1         = Token.new('frantic')
      has_match_2     = 'this matches'
      match_2         = Expression.new(
                          Token.new('this'),
                          Token.new(' '),
                          Token.new('matches')
                        )

      group 'given a string that starts with a match returns first match' do
        assert { matcher.match(has_match_1) == match_1 }
        assert { matcher.match(has_match_2) == match_2 }
      end

      group 'given a string without a match, returns falsy' do
        deny { matcher.match(no_match) }
      end

      group 'given a string with a match after the start' do
        group 'returns falsy when not given a starting index' do
          deny { matcher.match(has_later_match) }
        end

        group 'returns falsy when given a wrong starting index' do
          deny { matcher.match(has_later_match, starting_index + 1) }
          deny { matcher.match(has_later_match, starting_index - 1) }
        end

        group 'returns first match when given the starting index of the match' do
          assert { matcher.match(has_later_match, starting_index) == later_match }
        end
      end
    end
  end
end
