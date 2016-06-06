# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative './pattern_matcher_like'
require_relative '../build'
require_relative '../mismatch'

module Lextacular
  module Build
    group '.pattern_matcher' do
      pattern_matcher_like method(:pattern_matcher)

      group 'return falsy if any of the child patterns return falsy' do
        match = proc { 'truthy' }
        none  = proc { false }

        assert { !pattern_matcher(none              ).call('') }
        assert { !pattern_matcher(match, none       ).call('') }
        assert { !pattern_matcher(match, none, match).call('') }
      end

      group 'return falsy if the final result is empty' do
        assert { !pattern_matcher().call('') }
        assert { !pattern_matcher(proc { '' }).call('') }
        assert { !pattern_matcher(proc { [] }).call('') }
      end

      group 'if any child returns a Mismatch, return that same Mismatch' do
        mismatch = Mismatch.new
        match      = proc { 'truthy' }
        none       = proc { mismatch }

        assert { pattern_matcher(none              ).call('').equal?(mismatch) }
        assert { pattern_matcher(match, none       ).call('').equal?(mismatch) }
        assert { pattern_matcher(match, none, match).call('').equal?(mismatch) }
      end
    end
  end
end
