# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../helpers/with_falsy'
require_relative '../helpers/generic_tests/pattern_matcher_basics'
require_relative '../helpers/mocks/mock_matcher'
require_relative '../../matchers'
require_relative '../../mismatch'

module Lextacular
  module Matchers
    group '.pattern_matcher' do
      pattern_matcher_basics method(:pattern_matcher)

      group 'return falsy if any of the children return' do
        with_falsy do |falsy|
          yes = MockMatcher.new('truthy')
          no  = MockMatcher.new(falsy)

          assert { !pattern_matcher(no          ).call('', counts: Counts.new) }
          assert { !pattern_matcher(yes, no     ).call('', counts: Counts.new) }
          assert { !pattern_matcher(yes, no, yes).call('', counts: Counts.new) }
        end
      end

      group 'if any child returns a Mismatch, return that same Mismatch' do
        mismatch = Mismatch.new
        yes      = MockMatcher.new('truthy')
        no       = MockMatcher.new(mismatch)

        assert { pattern_matcher(no          ).call('', counts: Counts.new).equal?(mismatch) }
        assert { pattern_matcher(yes, no     ).call('', counts: Counts.new).equal?(mismatch) }
        assert { pattern_matcher(yes, no, yes).call('', counts: Counts.new).equal?(mismatch) }
      end
    end
  end
end
