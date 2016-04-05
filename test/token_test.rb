# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require '../Token'

module Lextacular
  group Token do
    content     = 'here is some text'
    empty_token = Token.new
    token       = Token.new(content)

    group '#content' do
      assert 'returns the content' do
        token.content == content
      end

      assert 'returns an empty string if initialized with nothing' do
        empty_token.content == ''
      end
    end

    group '#size' do
      assert 'returns the size of the content' do
        token.size == content.size
      end

      assert 'returns 0 if initialized with nothing' do
        empty_token.size.zero?
      end
    end

    group '#==' do
      assert 'returns true if self or a Token with the same content' do
        token == token && token == Token.new(content)
      end

      assert 'returns false if given anything else' do
        !(token == Token.new('something else')) &&
        !(token == content)
      end
    end

    assert 'can not have its content splatted' do
      [*token] == [token]
    end
  end
end
