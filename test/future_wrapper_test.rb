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
    group '#call' do
      assert 'calls the matcher stored in the hash' do
        was_called = false
        hash       = { example: proc { was_called = true } }

        FutureWrapper.new(:example, hash).call('')

        was_called
      end

      assert 'returns whatever the stored matcher returns' do
        result = 'fluffle bumble'
        hash   = { the_name: proc { result } }

        FutureWrapper.new(:the_name, hash).call('') == result
      end

      assert 'stored matcher can be added after creating the stored_proc' do
        hash   = {}
        stored = FutureWrapper.new(:sally, hash)

        was_called   = false
        hash[:sally] = proc { was_called = true }

        stored.call('')

        was_called
      end

      assert 'passes arguments to the stored matcher' do
        name         = :funky_func
        given_string = 'nope nope nope'
        given_index  = 88
        given_hash   = { y: :not? }

        result_string = nil
        result_index  = nil
        result_hash   = nil

        hash = {
                 name => proc do |string, index, counts:|
                   result_string = string
                   result_index  = index
                   result_hash   = counts
                 end
               }

        FutureWrapper.new(name, hash)
                     .call(given_string, given_index, counts: given_hash)

        assert { result_string == given_string }
        assert { result_index  == given_index }
        assert { result_hash   == given_hash }
      end

      group 'errs properly if matcher is not defined at call time' do
        stored = FutureWrapper.new(:never_defined, {})

        err(expect: KeyError) { stored.call('') }
      end

      group 'can extend the eigenclass of the result' do
        result = FutureWrapper.new(
                   :a,
                   { a: proc { 'hello' } },
                   defs: proc { def return_2; 2; end }
                 ).call('')

        assert { result.return_2 == 2 }
        err(expect: NoMethodError) { 'other string'.return_2 }
      end
    end

    group '#rename' do
      assert 'returns a new FutureWrapper' do
        FutureWrapper.new(:a, {}).rename(:x).is_a?(FutureWrapper)
      end

      assert 'returns a different object' do
        original = FutureWrapper.new(:a, {})

        FutureWrapper.new(:a, {}).rename(:x) != original
      end

      assert 'renames output of matcher' do
        old_name = :wrong
        new_name = :correct

        FutureWrapper.new(
                       :example,
                       {
                         example: MatchWrapper.new(
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
