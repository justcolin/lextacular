# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require '../node'
require '../group_node'

module Lextacular
  group GroupNode do
    content_1 = 'here is some text'
    content_2 = 'even more text!'
    content_3 = 'what?! more text?!'

    empty_group  = GroupNode.new
    group        = GroupNode.new(Node.new(content_1), Node.new(content_2))
    nested_group = GroupNode.new(group, content_3)

    group '#to_s' do
      assert 'returns the content of the children concatenated together' do
        group.to_s == content_1 + content_2
      end

      assert 'works with nested groups' do
        nested_group.to_s == group.to_s + content_3
      end

      assert 'returns an empty string when initialized with nothing' do
        empty_group.to_s == ''
      end
    end
  end
end
