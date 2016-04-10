# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'

class MockResult
  attr_reader :content

  def initialize *content
    @content = content
  end
end

module Lextacular
  group '.build_matcher' do
    group 'arguments from #call are passed into the given pattern matcher' do
      given_index  = rand
      given_string = (given_index + rand).to_s

      result_string = nil
      result_index  = nil

      pattern_matcher = proc do |string, index|
                          result_string = string
                          result_index  = index
                        end

      build_matcher(pattern_matcher).call(given_string, given_index)

      assert { result_string == given_string }
      assert { result_index  == given_index }
    end
  end
end
