# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require '../node'

module Lextacular
  group Node do
    content    = 'here is some text'
    empty_node = Node.new
    node       = Node.new(content)

    group '#to_s' do
      assert 'returns the content' do
        node.to_s == content
      end

      assert 'returns an empty string if initialized with nothing' do
        empty_node.to_s == ''
      end
    end

    group '#size' do
      assert 'returns the size of the content' do
        node.size == content.size
      end

      assert 'returns 0 if initialized with nothing' do
        empty_node.size.zero?
      end
    end

    group '.new' do
      assert 'given a block, evaluates it in the context of the object' do
        node_with_method = Node.new do
                             def returns_puppies
                               :puppies
                             end
                           end

        node_with_method.returns_puppies == :puppies
      end
    end
  end
end
