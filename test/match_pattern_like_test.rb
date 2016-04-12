# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'
require_relative '../mismatch'

def match_pattern_like make_matcher
  group 'return array of matches if all children return matches' do
    assert do
      rand_1 = rand.to_s
      rand_2 = rand_1 + rand.to_s
      rand_3 = rand_2 + rand.to_s

      make_matcher.call(
                    proc { rand_1 },
                    proc { rand_2 },
                    proc { rand_3 }
                  )
                  .call('') == [rand_1, rand_2, rand_3]
    end
  end

  group 'pass string and index into children, incrementing index as it goes' do
    given_index  = 10
    given_string = rand.to_s

    result_index_1  = nil
    result_index_2  = nil
    result_index_3  = nil
    result_string_2 = nil
    result_string_1 = nil
    result_string_3 = nil

    pattern = [
                proc do |string, index|
                  result_string_1 = string
                  result_index_1  = index

                  "12345678"
                end,
                proc do |string, index|
                  result_string_2 = string
                  result_index_2  = index

                  "123"
                end,
                proc do |string, index|
                  result_string_3 = string
                  result_index_3  = index

                  "something else"
                end
              ]

    make_matcher.call(*pattern).call(given_string, given_index)

    assert { result_string_1 == given_string }
    assert { result_string_2 == given_string }
    assert { result_string_3 == given_string }

    assert { result_index_1 == given_index }
    assert { result_index_2 == given_index + 8 }
    assert { result_index_3 == given_index + 11 }
  end

  group 'index defaults to 0' do
    result_index = nil
    index_proc   = proc do |_, index|
                     result_index = index
                     'stringy stringle string'
                   end

    make_matcher.call(index_proc).call('')

    assert { result_index.zero? }
  end
end

module Lextacular
  group '.match_pattern' do
    match_pattern_like method(:match_pattern)

    group 'return falsy if any of the child patterns return falsy' do
      yes = proc { 'truthy' }
      no  = proc { false }

      deny { match_pattern(no          ).call('') }
      deny { match_pattern(yes, no     ).call('') }
      deny { match_pattern(yes, no, yes).call('') }
    end

    group 'return falsy if the final result is empty' do
      deny { match_pattern().call('') }
      deny { match_pattern(proc { '' }).call('') }
      deny { match_pattern(proc { [] }).call('') }
    end

    group 'if any child returns a Mismatch, return that same Mismatch' do
      mismatch = Mismatch.new
      yes      = proc { 'truthy' }
      no       = proc { mismatch }

      assert { match_pattern(no          ).call('').equal?(mismatch) }
      assert { match_pattern(yes, no     ).call('').equal?(mismatch) }
      assert { match_pattern(yes, no, yes).call('').equal?(mismatch) }
    end
  end

  group '.match_maybe' do
    match_pattern_like method(:match_maybe)

    group 'return empty array if any of the child patterns return falsy' do
      yes = proc { 'truthy' }
      no  = proc { false }

      assert { match_maybe(no          ).call('') == [] }
      assert { match_maybe(yes, no     ).call('') == [] }
      assert { match_maybe(yes, no, yes).call('') == [] }
    end

    group 'return an empty array if any child returns a Mismatch' do
      mismatch = Mismatch.new
      yes      = proc { 'truthy' }
      no       = proc { mismatch }

      assert { match_maybe(no          ).call('') == [] }
      assert { match_maybe(yes, no     ).call('') == [] }
      assert { match_maybe(yes, no, yes).call('') == [] }
    end
  end
end
