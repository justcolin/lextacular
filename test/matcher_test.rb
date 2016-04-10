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

    group 'index argument defaults to 0' do
      result_index    = nil
      pattern_matcher = proc { |_, index| result_index = index }

      build_matcher(MockResult, pattern_matcher)
                   .call(given_string)

      assert { result_index.zero? }
    end

    group 'if the pattern matcher returns truthy' do
      group 'returns instance of the given class' do
        given_class = Class.new { def initialize *_; end }

        assert do
          build_matcher(given_class, proc { true })
                       .call('').is_a? given_class
        end
      end

      group 'returned object is initialized with the result of the pattern matcher' do
        proc_return = rand

        assert do
          build_matcher(MockResult, proc { proc_return })
                       .call('')
                       .content == [proc_return]
        end
      end

      group 'result of the pattern matcher is splatted into the result' do
        number_1 = rand
        number_2 = number_1 + rand
        result   = [number_1, number_2]

        assert do
          build_matcher(MockResult, proc { result })
                       .call('')
                       .content == result
        end
      end
    end

    group 'if the pattern matcher returns falsy' do
      mismatch_result = build_matcher(MockResult, proc { nil })
                                     .call(given_string, given_index)

      group 'returns instance of Mismatch' do
        assert { mismatch_result.is_a? Mismatch }
      end

      group 'Mismatch is given the string and index' do
        assert { mismatch_result.content == given_string }
        assert { mismatch_result.index   == given_index  }
      end
    end
  end

  group '.match_regexp' do
    group 'given a matching string, returns match content' do
      matcher = match_regexp(/bubbles/)

      assert { matcher.call('bubbles are fun') == 'bubbles' }
    end

    group 'given a non-matching string, returns falsy' do
      matcher = match_regexp(/never found/)

      deny { matcher.call('something else') }
    end

    group 'given a string that matches later' do
      matcher     = match_regexp(/bloop/)
      later_match = 'blip bloop'
      match_index = 5

      group 'returns falsy if index is not given' do
        deny { matcher.call(later_match) }
      end

      group 'returns falsy if index is wrong' do
        deny { matcher.call(later_match, match_index + 1) }
        deny { matcher.call(later_match, match_index - 1) }
      end
    end
  end
end
