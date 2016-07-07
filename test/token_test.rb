# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../token'
require_relative './helpers/match_result_basics'

module Lextacular
  group Token do
    match_result_basics Token

    content     = 'here is some text'
    empty_token = Token.new
    token       = Token.new(content)

    group '#to_s' do
      assert 'returns the content' do
        token.to_s == content
      end

      assert 'returns an empty string if initialized with nothing' do
        empty_token.to_s == ''
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

    group '#empty?' do
      assert 'returns truthy when size == 0' do
        empty_token.empty?
      end

      assert 'returns falsy when size > 0' do
        !token.empty?
      end
    end

    group '#without_temps' do
      assert 'returns self when temp is not set' do
        token = Token.new
        token.without_temps == token
      end

      assert 'returns nil when temp is true' do
        token = Token.new(temp: true)
        token.without_temps.nil?
      end

      assert 'returns self when temp is false' do
        token = Token.new(temp: false)
        token.without_temps == token
      end
    end

    assert 'can not have its content splatted' do
      [*token] == [token]
    end
  end
end
