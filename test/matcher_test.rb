# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './tet'
require_relative './mocks'
require_relative '../token'
require_relative '../expression'
require_relative '../matchers'

def matcher_like klass, pattern:, match_content:, matching:, return_class:,
                        no_match:, later_match:, starting_index:
  group klass do
    group '#match' do
      matcher = klass.new(pattern, return_class)

      group 'given a string that starts with a match' do
        group 'returns instance of the class given at initialization' do
          given_mock = klass.new(pattern, MockMatcherReturn)
                            .match(matching)

          given_other = klass.new(pattern, return_class)
                             .match(matching)

          assert { given_mock.is_a?(MockMatcherReturn) }
          assert { given_other.is_a?(return_class) }
        end

        group 'return has the proper content' do
          match = klass.new(pattern, return_class)
                       .match(matching)

          assert { match == return_class.new(*match_content) }
        end
      end

      group 'given a string without a match, returns falsy' do
        deny { matcher.match(no_match) }
      end

      group 'given a string with a match after the start' do
        group 'returns falsy when not given a starting index' do
          deny { matcher.match(later_match) }
        end

        group 'returns falsy when given a wrong starting index' do
          deny { matcher.match(later_match, starting_index - 1) }
          deny { matcher.match(later_match, starting_index + 1) }
        end

        group 'returns match when given the starting index of the match' do
          assert { matcher.match(later_match, starting_index) }
        end
      end

      yield if block_given?
    end
  end
end

module Lextacular
  matcher_like TokenMatcher,
               matching:       'hello world',
               pattern:        /hello/,
               match_content:  'hello',
               no_match:       'goodbye for now',
               later_match:    'I say hello',
               starting_index: 6,
               return_class:   Token

  matcher_like ExpressionMatcher,
               matching:       'puppy time is all the time',
               pattern:        [
                                 TokenMatcher.new(/puppy/, Token),
                                 TokenMatcher.new(/ /, Token),
                                 TokenMatcher.new(/time/, Token)
                               ],
               match_content:  [
                                 Token.new('puppy'),
                                 Token.new(' '),
                                 Token.new('time')
                               ],
               no_match:       'kitten time',
               later_match:    'it is puppy time',
               starting_index: 6,
               return_class:   Expression do

    group 'matches when there are nested ExpressionMatchers' do
      word_matcher = TokenMatcher.new(/\w+/, Token)

      method_matcher = ExpressionMatcher.new(
                         [TokenMatcher.new(/\./, Token), word_matcher],
                         Expression
                       )

      nested_matcher = ExpressionMatcher.new(
                         [word_matcher, method_matcher],
                         Expression
                       )

      match = Expression.new(
                Token.new('foo'),
                Expression.new(Token.new('.'), Token.new('bar'))
              )

      assert { nested_matcher.match('foo.bar') == match }
    end

    group 'expands TempExpressions' do
      word_matcher = TokenMatcher.new(/\w+/, Token)

      method_matcher = ExpressionMatcher.new(
                         [TokenMatcher.new(/\./, Token), word_matcher],
                         TempExpression
                       )

      nested_matcher = ExpressionMatcher.new(
                         [word_matcher, method_matcher],
                         Expression
                       )

      match = Expression.new(Token.new('foo'), Token.new('.'), Token.new('bar'))

      assert { nested_matcher.match('foo.bar') == match }
    end
  end
end
