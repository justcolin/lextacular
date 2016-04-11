# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'
require_relative '../mismatch'

def returns_falsy_if_any_are falsy
  yes = proc { 'truthy' }
  no  = proc { falsy }

  deny { match_repeat(no          ).call('') }
  deny { match_repeat(yes, no     ).call('') }
  deny { match_repeat(yes, no, yes).call('') }
end

module Lextacular
  group '.match_repeat' do
    group 'returns falsy' do
      group 'if any children return falsy' do
        yes = proc { 'truthy' }
        no  = proc { nil }

        deny { match_repeat(no          ).call('') }
        deny { match_repeat(yes, no     ).call('') }
        deny { match_repeat(yes, no, yes).call('') }
      end

      group 'if any children return a Mismatch' do
        yes = proc { 'truthy' }
        no  = proc { Mismatch.new }

        deny { match_repeat(no          ).call('') }
        deny { match_repeat(yes, no     ).call('') }
        deny { match_repeat(yes, no, yes).call('') }
      end
    end
  end
end
