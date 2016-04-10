# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'
require_relative '../mismatch'

class MockResult
  attr_reader :content

  def initialize *content
    @content = content
  end
end

module Lextacular
  group '.build_matcher' do
    given_index  = rand
    given_string = (given_index + rand).to_s

    group 'arguments from #call are passed into the given pattern matcher' do
      result_string = nil
      result_index  = nil

      pattern_matcher = proc do |string, index|
                          result_string = string
                          result_index  = index
                        end

      build_matcher(MockResult, pattern_matcher)
                   .call(given_string, given_index)

      assert { result_string == given_string }
      assert { result_index  == given_index }
    end

    group 'returns instance of the given class if the pattern matcher returns truthy' do
      assert do
        given_class = Class.new

        build_matcher(given_class, proc { true })
                     .call.is_a? given_class
      end
    end

    mismatch_result = build_matcher(MockResult, proc { nil })
                                   .call(given_string, given_index)

    group 'returns instance of Mismatch if the pattern matcher returns falsy' do
      assert { mismatch_result.is_a? Mismatch }
    end

    group 'Mismatch is given the string and index' do
      assert { mismatch_result.content == given_string }
      assert { mismatch_result.index   == given_index  }
    end
  end
end
