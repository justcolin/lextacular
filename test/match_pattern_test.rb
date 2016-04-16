# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative './match_pattern_like'
require_relative '../matcher_building'
require_relative '../mismatch'

module Lextacular
  module MatcherBuilding
    group '.match_pattern' do
      match_pattern_like method(:match_pattern)

      group 'return falsy if any of the child patterns return falsy' do
        yes = proc { 'truthy' }
        no  = proc { false }

        deny { match_pattern(no          ).call('') }
        deny { match_pattern(yes, no     ).call('') }
        deny { match_pattern(yes, no, yes).call('') }
      end

      group 'return falsy if the final result is empty' do
        deny { match_pattern().call('') }
        deny { match_pattern(proc { '' }).call('') }
        deny { match_pattern(proc { [] }).call('') }
      end

      group 'if any child returns a Mismatch, return that same Mismatch' do
        mismatch = Mismatch.new
        yes      = proc { 'truthy' }
        no       = proc { mismatch }

        assert { match_pattern(no          ).call('').equal?(mismatch) }
        assert { match_pattern(yes, no     ).call('').equal?(mismatch) }
        assert { match_pattern(yes, no, yes).call('').equal?(mismatch) }
      end
    end
  end
end
