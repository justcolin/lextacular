# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../token'

module Lextacular
  group Token do
    content     = 'here is some text'
    empty_token = Token.new
    token       = Token.new(content)

    group '#to_s' do
      group 'returns the content' do
        assert { token.to_s == content }
      end

      group 'returns an empty string if initialized with nothing' do
        assert { empty_token.to_s == '' }
      end
    end

    group '#size' do
      group 'returns the size of the content' do
        assert { token.size == content.size }
      end

      group 'returns 0 if initialized with nothing' do
        assert { empty_token.size.zero? }
      end
    end

    group '#empty?' do
      group 'returns truthy when size == 0' do
        assert { empty_token.empty? }
      end

      group 'returns falsy when size > 0' do
        deny { token.empty? }
      end
    end

    group '#==' do
      group 'returns true if self or a Token with the same content' do
        assert { token == token }
        assert { token == Token.new(content) }
      end

      group 'returns false if given anything else' do
        deny { token == Token.new('something else') }
        deny { token == content }
      end
    end

    group 'can not have its content splatted' do
      assert { [*token] == [token] }
    end
  end
end
