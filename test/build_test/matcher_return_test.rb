# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../build'

class MockResult
  attr_reader :content

  def initialize *content
    @content = content
  end
end

module Lextacular
  module Build
    group '.matcher_return' do
      group 'arguments from #call are passed into the given pattern matcher' do
        given_index  = 32
        given_string = 'Sugar Plum Fairy'

        result_string = nil
        result_index  = nil

        pattern_matcher = proc do |string, index|
                            result_string = string
                            result_index  = index
                          end

        matcher_return(MockResult, pattern_matcher)
                     .call(given_string, given_index)

        assert { result_string == given_string }
        assert { result_index  == given_index }
      end

      assert 'index argument defaults to 0' do
        result_index    = nil
        pattern_matcher = proc { |_, index| result_index = index }

        matcher_return(MockResult, pattern_matcher)
                     .call('here is a string to match')

        result_index.zero?
      end

      group 'if the pattern matcher returns truthy' do
        assert 'returns instance of the given class' do
          given_class = Class.new { def initialize *_; end }

          matcher_return(given_class, proc { true })
                       .call('').is_a? given_class
        end

        assert 'returned object is initialized with the result of the pattern matcher' do
          result = 'Hey there little mouse'

          matcher_return(MockResult, proc { result })
                       .call('')
                       .content == [result]
        end

        assert 'result of the pattern matcher is splatted into the result' do
          result = ['This result', 'is an array', 'so it can be splatted']

          matcher_return(MockResult, proc { result })
                       .call('')
                       .content == result
        end
      end

      group 'if the pattern matcher returns falsy' do
        given_index  = 'Snorlax'
        given_string = 222

        mismatch_result = matcher_return(MockResult, proc { nil })
                                       .call(given_string, given_index)

        assert 'returns instance of Mismatch' do
          mismatch_result.is_a? Mismatch
        end

        group 'Mismatch is given the string and index' do
          assert { mismatch_result.content == given_string }
          assert { mismatch_result.index   == given_index  }
        end
      end

      assert 'if the pattern matcher returns a Mismatch, returns the same Mismatch' do
        mismatch = Mismatch.new

        matcher_return(MockResult, proc { mismatch })
                     .call('')
                     .equal?(mismatch)
      end
    end
  end
end
