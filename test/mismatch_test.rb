# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../mismatch'

class MockResult
  attr_reader :content

  def initialize *content
    @content = content
  end
end

module Lextacular
  group Mismatch do
    given_index  = rand
    given_string = (given_index + rand).to_s
    example      = Mismatch.new(given_string, given_index)

    assert '#content returns the string given at initialization' do
      example.content == given_string
    end

    assert '#index returns the index given at initialization' do
      example.index == given_index
    end
  end
end
