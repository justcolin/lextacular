# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require '../node'

group Node do
  content = 'here is some text'
  node    = Node.new(content)

  group '#to_s' do
    assert 'returns the content' do
      node.to_s == content
    end
  end
end
