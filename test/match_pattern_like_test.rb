# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../matcher'

def match_pattern_like
  group 'returns array of matches if all children return matches' do
    assert do
      rand_1 = rand
      rand_2 = rand
      rand_3 = rand

      yield(proc { rand_1 }, proc { rand_2 }, proc { rand_3 })
           .call('') == [rand_1, rand_2, rand_3]
    end
  end

  group 'passes string and index into children' do
    given_index  = rand
    given_string = (given_index + rand).to_s

    result_index_1  = nil
    result_index_2  = nil
    result_string_1 = nil
    result_string_2 = nil

    pattern = [
                proc do |string, index|
                  result_string_1 = string
                  result_index_1  = index
                end,
                proc do |string, index|
                  result_string_2 = string
                  result_index_2  = index
                end
              ]

    yield(*pattern).call(given_string, given_index)

    assert { result_string_1 == given_string }
    assert { result_string_2 == given_string }
    assert { result_index_1  == given_index  }
    assert { result_index_2  == given_index  }
  end

  group 'index defaults to 0' do
    result_index = nil
    index_proc   = proc { |_, index| result_index = index }

    yield(index_proc).call('')

    assert { result_index.zero? }
  end
end

module Lextacular
  group '.match_pattern' do
    match_pattern_like { |*args| match_pattern(*args) }

    group 'returns falsy if any of the child matchers return falsy' do
      yes = proc { true }
      no  = proc { false }

      deny { match_pattern(no).call('') }
      deny { match_pattern(yes, no).call('') }
      deny { match_pattern(no,  yes, yes).call('') }
      deny { match_pattern(yes, no,  yes).call('') }
      deny { match_pattern(yes, no,  no).call('') }
    end
  end

  group '.match_maybe' do
    match_pattern_like { |*args| match_maybe(*args) }

    group 'returns an empty array if any of the child patterns return falsy' do
      yes = proc { true }
      no  = proc { false }

      assert { match_maybe(no).call('')            == [] }
      assert { match_maybe(yes, no).call('')       == [] }
      assert { match_maybe(no,  yes, yes).call('') == [] }
      assert { match_maybe(yes, no,  yes).call('') == [] }
      assert { match_maybe(yes, no,  no).call('')  == [] }
    end
  end
end
