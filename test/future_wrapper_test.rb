# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../match_wrapper'
require_relative '../token'
require_relative '../future_wrapper'

module Lextacular
  group FutureWrapper do
    key = :funky_func

    group '#call' do
      assert 'calls the matcher stored in the hash' do
        was_called = false
        hash       = { key => proc { was_called = true } }

        FutureWrapper.new(key, hash).call('')

        was_called
      end

      assert 'returns whatever the stored matcher returns' do
        result = 'fluffle bumble'
        hash   = { key => proc { result } }

        FutureWrapper.new(key, hash).call('') == result
      end

      assert 'stored matcher can be added after creating the wrapper' do
        hash    = {}
        wrapper = FutureWrapper.new(key, hash)

        was_called = false
        hash[key]  = proc { was_called = true }

        wrapper.call('')

        was_called
      end

      group 'errs properly if matcher is not defined at call time' do
        stored = FutureWrapper.new(:never_defined, {})

        err(expect: KeyError) { stored.call('') }
      end

      assert 'passes arguments to the stored matcher' do
        given_string = 'nope nope nope'
        given_index  = 88
        given_counts = { example: 34 }

        result_string = nil
        result_index  = nil
        result_counts = nil

        hash = {
                 key => proc do |string, index, counts:|
                   result_string = string
                   result_index  = index
                   result_counts = counts
                 end
               }

        FutureWrapper.new(key, hash)
                     .call(given_string, given_index, counts: given_counts)

        assert { result_string == given_string }
        assert { result_index  == given_index }
        assert { result_counts == given_counts }
      end

      group 'can extend the eigenclass of the result' do
        assert do
          FutureWrapper.new(
                         key,
                         { key => proc { 'a match' } },
                         defs: proc { def return_2; 2; end }
                       )
                       .call('')
                       .return_2 == 2
        end

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

        FutureWrapper.new(
                       key,
                       {
                         key => MatchWrapper.new(
                                  Token,
                                  proc { 'truthy' },
                                  name: old_name
                                )
                       }
                     )
                     .rename(new_name)
                     .call('')
                     .name == new_name
      end
    end
  end
end
