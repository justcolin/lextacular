# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'
require_relative '../mismatch'

module Lextacular
  group '.match_either' do
    group 'returns falsy if all children return falsy or Mismatches' do
      deny do
        match_either(
          proc { nil },
          proc { false },
          proc { Mismatch }
        ).call('')
      end
    end
  end
end
