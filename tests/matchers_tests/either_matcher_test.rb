# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../helpers/mocks/mock_matcher'
require_relative '../../matchers'
require_relative '../../counts'
require_relative '../../mismatch'

module Lextacular
  module Matchers
    group '.either_matcher' do
      group 'passes string and index into children' do
        string = 'Forsooth!'
        index  = 999
        counts = Counts.new

        first  = MockMatcher.new(false)
        second = MockMatcher.new(false)

        either_matcher(first, second).call(string, index, counts: counts)

        assert {  first.given?(string, index, counts) }
        assert { second.given?(string, index, counts) }
      end

      assert 'returns falsy if all children return falsy or Mismatches' do
        !either_matcher(
                         MockMatcher.new(nil),
                         MockMatcher.new(false),
                         MockMatcher.new(Mismatch.new)
                       )
                       .call('', counts: Counts.new)
      end

      group 'returns the first match if any child matches' do
        first  = 'Oooooo, Ford Focus'
        second = 'The example above is an obscure song reference'

        no    = MockMatcher.new(nil)
        yes_1 = MockMatcher.new(first)
        yes_2 = MockMatcher.new(second)

        assert { either_matcher(yes_1           ).call('', counts: Counts.new) == first }
        assert { either_matcher(yes_1, yes_2    ).call('', counts: Counts.new) == first }
        assert { either_matcher(no, yes_1, yes_2).call('', counts: Counts.new) == first }
      end

      group 'resets the counts hash each time if there are no matches' do
        counts           = Counts.new
        counts[:the_key] = 48
        original_counts  = counts.dup

        first  = MockMatcher.new(false) { |counts:| counts.replace(Counts.new) }
        second = first.dup

        either_matcher(first, second).call('', counts: counts)

        assert { first.given_counts  == original_counts }
        assert { second.given_counts == original_counts }
      end
    end
  end
end
