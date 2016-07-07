# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../helpers/pattern_matcher_basics'
require_relative '../../build'
require_relative '../../mismatch'

module Lextacular
  module Build
    group '.maybe_matcher' do
      pattern_matcher_basics method(:maybe_matcher)

      group 'return empty array if any of the child patterns return falsy' do
        yes = proc { 'truthy' }
        no  = proc { false }

        assert { maybe_matcher(no          ).call('') == [] }
        assert { maybe_matcher(yes, no     ).call('') == [] }
        assert { maybe_matcher(yes, no, yes).call('') == [] }
      end

      group 'return an empty array if any child returns a Mismatch' do
        mismatch = Mismatch.new
        yes      = proc { 'truthy' }
        no       = proc { mismatch }

        assert { maybe_matcher(no          ).call('') == [] }
        assert { maybe_matcher(yes, no     ).call('') == [] }
        assert { maybe_matcher(yes, no, yes).call('') == [] }
      end
    end
  end
end
