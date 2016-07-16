# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../helpers/with_falsy'
require_relative '../helpers/pattern_matcher_basics'
require_relative '../../matchers'
require_relative '../../mismatch'

module Lextacular
  module Matchers
    group '.maybe_matcher' do
      pattern_matcher_basics method(:maybe_matcher)

      group 'return empty array if any of the child patterns return' do
        with_falsy do |falsy|
          yes = proc { 'truthy' }
          no  = proc { falsy }

          assert { maybe_matcher(no          ).call('', counts: {}) == [] }
          assert { maybe_matcher(yes, no     ).call('', counts: {}) == [] }
          assert { maybe_matcher(yes, no, yes).call('', counts: {}) == [] }
        end
      end

      group 'return an empty array if any child returns a Mismatch' do
        mismatch = Mismatch.new
        yes      = proc { 'truthy' }
        no       = proc { mismatch }

        assert { maybe_matcher(no          ).call('', counts: {}) == [] }
        assert { maybe_matcher(yes, no     ).call('', counts: {}) == [] }
        assert { maybe_matcher(yes, no, yes).call('', counts: {}) == [] }
      end
    end
  end
end
