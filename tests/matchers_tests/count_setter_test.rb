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
    group '.count_setter' do
      assert 'passes string, index and counts into child matcher' do
        string  = 'hibble'
        index   = 8462
        counts  = Counts.new
        matcher = MockMatcher.new(MockResult.new)

        count_setter(matcher)
                    .call(string, index, counts: counts)

        matcher.given?(string, index, counts)
      end

      group 'returns whatever the child matcher returned if child returns' do
        with_falsy_and_mismatch do |falsy|
          result = count_setter(MockMatcher.new(falsy))
                               .call('', counts: Counts.new)

          assert { result == falsy }
        end

        assert 'a match' do
          matcher = MockMatcher.new(MockResult.new)
          result  = count_setter(matcher)
                                .call('', counts: Counts.new)

          result == matcher.result
        end
      end

      assert 'updates the counts hash with the length of the match' do
        name    = :a_so_so_name
        content = 'hippos'
        counts  = Counts.new

        count_setter(MockMatcher.new(MockResult.new(content, name: name)))
                    .call('', counts: counts)

        counts[name] == content.size
      end

      group 'does not update the counts hash when the matcher returns' do
        with_falsy_and_mismatch do |falsy|
          name      = :a_slightly_better_name
          counts    = Counts.new
          old_value = counts[name]

          count_setter(MockMatcher.new(falsy))
                      .call('', counts: counts)

          assert { counts[name] == old_value }
        end
      end
    end
  end
end
