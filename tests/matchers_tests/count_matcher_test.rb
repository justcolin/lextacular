# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../helpers/with_falsy_and_mismatch'
require_relative '../helpers/mocks/mock_matcher'
require_relative '../helpers/mocks/mock_result'
require_relative '../../matchers'
require_relative '../../counts'

module Lextacular
  module Matchers
    group '.count_matcher' do
      assert 'passes string, index and counts into child matcher' do
        string  = 'holy smokes'
        index   = 634
        counts  = Counts.new
        matcher = MockMatcher.new(MockResult.new)

        count_matcher(matcher, :==)
                     .call(string, index, counts: counts)

        matcher.given?(string, index, counts)
      end

      group 'returns whatever the child matcher returned if' do
        group 'child returns' do
          with_falsy_and_mismatch do |falsy|
            result = count_matcher(MockMatcher.new(falsy), :==)
                                  .call('', counts: Counts.new)

            assert { result == falsy }
          end
        end

        group 'the comparison method returns true' do
          name         = :a_great_name
          expected     = MockResult.new('here is some text', name: name)
          matcher      = MockMatcher.new(expected)
          counts       = Counts.new
          counts[name] = matcher.result_size

          result = count_matcher(matcher, :==)
                                .call('', counts: counts)

          assert { result == expected }

          assert 'no matter what the method' do
            counts[name] += 1
            result        = count_matcher(matcher, :<)
                                         .call('', counts: counts)

            result == matcher.result
          end
        end
      end

      group 'returns falsy if the comparison method returns false' do
        name         = :an_even_greater_name
        expected     = MockResult.new('here is more text', name: name)
        matcher      = MockMatcher.new(expected)
        counts       = Counts.new
        counts[name] = matcher.result_size + 1

        assert do
          !count_matcher(matcher, :==).call('', counts: counts)
        end

        assert 'no matter what the method' do
          !count_matcher(matcher, :>).call('', counts: counts)
        end
      end
    end
  end
end
