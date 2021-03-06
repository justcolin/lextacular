# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative '../../mismatch'

def with_falsy_and_mismatch
  group 'false' do
    yield false
  end

  group 'nil' do
    yield nil
  end

  group 'a Mismatch' do
    yield Lextacular::Mismatch.new
  end
end
