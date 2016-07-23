# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative 'helpers/mocks/mock_matcher'
require_relative '../match_wrapper'
require_relative '../counts'
require_relative '../token'
require_relative '../future_wrapper'

module Lextacular
  group FutureWrapper do
    key = :funky_func

    group '#call' do
      assert 'calls the matcher stored in the hash' do
        was_called = false
        hash       = { key => MockMatcher.new { was_called = true } }

        FutureWrapper.new(key, hash)
                     .call('', counts: Counts.new)

        was_called
      end

      assert 'returns whatever the stored matcher returns' do
        result = 'fluffle bumble'
        hash   = { key => MockMatcher.new(result) }

        FutureWrapper.new(key, hash).call('', counts: Counts.new) == result
      end

      assert 'stored matcher can be added after creating the wrapper' do
        hash    = {}
        wrapper = FutureWrapper.new(key, hash)

        was_called = false
        hash[key]  = MockMatcher.new { was_called = true }

        wrapper.call('', counts: Counts.new)

        was_called
      end

      group 'errs properly if matcher is not defined at call time' do
        stored = FutureWrapper.new(:never_defined, {})

        err(expect: KeyError) { stored.call('', counts: Counts.new) }
      end

      assert 'passes arguments to the stored matcher' do
        string  = 'nope nope nope'
        index   = 88
        counts  = Counts.new
        matcher = MockMatcher.new
        hash    = { key => matcher }

        FutureWrapper.new(key, hash)
                     .call(string, index, counts: counts)

        matcher.given?(string, index, counts)
      end

      group 'can extend the eigenclass of the result' do
        hash   = { key => MockMatcher.new }
        result = FutureWrapper.new(key, hash, defs: proc { def return_2; 2; end })
                              .call('', counts: Counts.new)
                              .return_2

        assert { result == 2 }
        err(expect: NoMethodError) { 'other string'.return_2 }
      end
    end

    group '#rename' do
      assert 'returns a new FutureWrapper' do
        FutureWrapper.new(key, {}).rename(:x).is_a?(FutureWrapper)
      end

      assert 'returns a different object' do
        key      = :something
        original = FutureWrapper.new(key, {})

        FutureWrapper.new(key, {}).rename(:x) != original
      end

      assert 'renames output of matcher' do
        old_name = :wrong
        new_name = :correct
        key      = :example
        hash     = { key => MatchWrapper.new(Token, MockMatcher.new, name: old_name) }

        result = FutureWrapper.new(key, hash)
                              .rename(new_name)
                              .call('', counts: Counts.new)
                              .name

        result == new_name
      end
    end
  end
end
