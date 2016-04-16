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
    group '.match_maybe' do
      match_pattern_like method(:match_maybe)

      group 'return empty array if any of the child patterns return falsy' do
        yes = proc { 'truthy' }
        no  = proc { false }

        assert { match_maybe(no          ).call('') == [] }
        assert { match_maybe(yes, no     ).call('') == [] }
        assert { match_maybe(yes, no, yes).call('') == [] }
      end

      group 'return an empty array if any child returns a Mismatch' do
        mismatch = Mismatch.new
        yes      = proc { 'truthy' }
        no       = proc { mismatch }

        assert { match_maybe(no          ).call('') == [] }
        assert { match_maybe(yes, no     ).call('') == [] }
        assert { match_maybe(yes, no, yes).call('') == [] }
      end
    end
  end
end
