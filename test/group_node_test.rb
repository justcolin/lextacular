# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require '../nodes'

def group_node_like klass
  group klass do
    content_1 = 'here is some text'
    content_2 = 'even more text!'
    content_3 = 'what?! more text?!'

    basic_group_content = [
                            Lextacular::Node.new(content_1),
                            Lextacular::Node.new(content_2)
                          ]

    empty_group  = klass.new
    basic_group  = klass.new(*basic_group_content)
    nested_group = klass.new(basic_group, content_3)

    group '#to_s' do
      assert 'returns the content of the children concatenated together' do
        basic_group.to_s == content_1 + content_2
      end

      assert 'works with nested groups' do
        nested_group.to_s == basic_group.to_s + content_3
      end

      assert 'returns an empty string when initialized with nothing' do
        empty_group.to_s == ''
      end
    end

    group '#size' do
      assert 'returns the sum of the sizes of all the children' do
        basic_group.size == content_1.size + content_2.size
      end

      assert 'works with nested groups' do
        nested_group.size == basic_group.size + content_3.size
      end

      assert 'returns 0 when initialized with nothing' do
        empty_group.size == 0
      end
    end

    yield basic_group, basic_group_content
  end
end

group_node_like Lextacular::GroupNode do |basic_group, content|
  assert 'can not have its content splatted' do
    [*basic_group] == [basic_group]
  end
end

group_node_like Lextacular::TempGroupNode do |basic_group, content|
  assert 'can have its content splatted' do
    [*basic_group] == [*content]
  end
end
