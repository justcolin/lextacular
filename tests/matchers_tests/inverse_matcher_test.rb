# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../matchers'
require_relative '../../counts'
require_relative '../helpers/with_falsy_and_mismatch'
require_relative '../helpers/mocks/mock_matcher'

module Lextacular
  module Matchers
    group '.inverse_matcher' do
      example = 'skiffle scuffle'

      group 'passes string, index and counts into children' do
        string = 'hello hello'
        index  = 1
        counts = Counts.new

        first  = MockMatcher.new
        second = MockMatcher.new
        third  = MockMatcher.new

        inverse_matcher(first, second, third).call(string, index, counts: counts)

        assert {  first.given?(string, index, counts) }
        assert { second.given?(string, index, counts) }
        assert {  third.given?(string, index, counts) }
      end

      group 'matches string when' do
        group 'one of the matchers returns' do
          with_falsy_and_mismatch do |falsy|
            result = inverse_matcher(regexp_matcher(/sk/), MockMatcher.new(falsy))
                                    .call(example, counts: Counts.new)

            assert { result == example }
          end
        end

        assert 'not all of the given matchers match' do
          inverse_matcher(regexp_matcher(/skiffle/), regexp_matcher(/-/))
                         .call(example, counts: Counts.new) == example
        end

        assert 'given an index past a match' do
          inverse_matcher(regexp_matcher(/ /))
                         .call(example, 8, counts: Counts.new) == 'scuffle'
        end

        assert 'given pattern which eventually matches' do
          inverse_matcher(regexp_matcher(/ /))
                         .call(example, counts: Counts.new) == 'skiffle'
        end

        assert 'pattern returns an array of empty elements' do
          inverse_matcher(MockMatcher.new(['', '']))
                         .call(example, counts: Counts.new) == example
        end
      end

      group 'does not match when' do
        assert 'string starts with a match' do
          !inverse_matcher(regexp_matcher(/s/))
                          .call(example, counts: Counts.new)
        end

        assert 'the whole pattern matches' do
          !inverse_matcher(regexp_matcher(/s/), regexp_matcher(/k/))
                          .call(example, counts: Counts.new)
        end

        assert 'given the index of a match' do
          !inverse_matcher(regexp_matcher(/ /), regexp_matcher(/scuffle/))
                          .call(example, 7, counts: Counts.new)
        end
      end
    end
  end
end
