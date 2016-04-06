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

def matcher_like klass, pattern:, match_content:, matching:, return_class:,
                        no_match:, later_match:, starting_index:
  group klass do
    group '#match' do
      matcher = klass.new(pattern, return_class)

      group 'given a string that starts with a match' do
        assert 'returns instance of the class given at initialization' do
          given_mock = klass.new(pattern, MockMatcherReturn)
                            .match(matching)

          given_other = klass.new(pattern, return_class)
                             .match(matching)

          given_mock.is_a?(MockMatcherReturn) &&
          given_other.is_a?(return_class)
        end

        assert 'return has the proper content' do
          match = klass.new(pattern, return_class)
                       .match(matching)

          match == return_class.new(match_content)
        end
      end

      assert 'given a string without a match, returns falsy' do
        !matcher.match(no_match)
      end

      group 'given a string with a match after the start' do
        assert 'returns falsy when not given a starting index' do
          !matcher.match(later_match)
        end

        assert 'returns falsy when given a wrong starting index' do
          !matcher.match(later_match, starting_index - 1) &&
          !matcher.match(later_match, starting_index + 1)
        end

        assert 'returns match when given the starting index of the match' do
          matcher.match(later_match, starting_index)
        end
      end
    end
  end
end

matcher_like Lextacular::TokenMatcher,
             pattern:        /hello/,
             matching:       'hello world',
             match_content:  'hello',
             no_match:       'goodbye for now',
             later_match:    'I say hello',
             starting_index: 6,
             return_class:   Lextacular::Token
