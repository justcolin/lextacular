# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../match_wrapper'
require_relative './helpers/with_falsy.rb'
require_relative './helpers/mock_result.rb'
require_relative './helpers/mock_temp.rb'
require_relative './helpers/mock_array.rb'

module Lextacular
  group MatchWrapper do
    group '#==' do
      wrapper = MockResult
      matcher = proc {}
      name    = :a
      temp    = true
      defs    = proc {}
      example = MatchWrapper.new(
                  wrapper,
                  matcher,
                  name: name,
                  temp: temp,
                  defs: defs
                )

      group 'returns true when given values are the same' do
        assert do
          example == MatchWrapper.new(
                       wrapper,
                       matcher,
                       name: name,
                       temp: temp,
                       defs: defs
                     )
        end

        group 'treats nil and false as the same' do
          assert 'name' do
            MatchWrapper.new(wrapper, matcher, name: false, temp: temp, defs: defs) ==
            MatchWrapper.new(wrapper, matcher, name: nil,   temp: temp, defs: defs)
          end

          assert 'temp' do
            MatchWrapper.new(wrapper, matcher, name: name, temp: false, defs: defs) ==
            MatchWrapper.new(wrapper, matcher, name: name, temp: nil,   defs: defs)
          end

          assert 'defs' do
            MatchWrapper.new(wrapper, matcher, name: name, temp: temp, defs: false) ==
            MatchWrapper.new(wrapper, matcher, name: name, temp: temp, defs: nil)
          end
        end
      end

      group 'returns false when any value is changed' do
        assert 'class' do
          example != MatchWrapper.new(
                       MockArray,
                       matcher,
                       name: name,
                       temp: temp,
                       defs: defs
                     )
        end

        assert 'matcher' do
          example != MatchWrapper.new(
                       wrapper,
                       nil,
                       name: name,
                       temp: temp,
                       defs: defs
                     )
        end

        assert 'name' do
          example != MatchWrapper.new(
                       wrapper,
                       matcher,
                       name: nil,
                       temp: temp,
                       defs: defs
                     )
        end

        assert 'temp' do
          example != MatchWrapper.new(
                       wrapper,
                       matcher,
                       name: name,
                       temp: nil,
                       defs: defs
                     )
        end

        assert 'defs' do
          example != MatchWrapper.new(
                       wrapper,
                       matcher,
                       name: name,
                       temp: temp,
                       defs: nil
                     )
        end
      end
    end

    group '#rename' do
      original = MatchWrapper.new(
                   MockResult,
                   proc { "stuff" },
                   name: :Abe,
                   temp: true,
                   defs: proc do
                           def returns_stuff
                             :stuff
                           end
                         end
                 )

      new_name = :Lincoln
      renamed  = original.rename(new_name)

      assert 'returns a MatchWrapper' do
        renamed.is_a?(MatchWrapper)
      end

      assert 'returns a different object' do
        !renamed.equal?(original)
      end

      assert 'passes the class extensions given on init' do
        renamed.call('').returns_stuff == :stuff
      end

      assert 'returns the same result, but with a new name' do
        renamed_result  = renamed.call('')
        original_result = original.call('')

        assert { renamed_result.is_a?(MockResult) && original_result.is_a?(MockResult)
        assert { renamed_result.content         == original_result.content }}
        assert { renamed_result.metadata[:name] == new_name }
        assert { renamed_result.metadata[:temp] == original_result.metadata[:temp] }
      end
    end

    group '#call' do
      group 'arguments are passed into the given matcher' do
        given_index   = 32
        given_string  = 'Sugar Plum Fairy'
        given_counts  = { q: :terrible_character }
        result_string = nil
        result_index  = nil
        result_counts = nil

        pattern_matcher = proc do |string, index, counts:|
                            result_string = string
                            result_index  = index
                            result_counts = counts
                          end

        MatchWrapper.new(MockResult, pattern_matcher)
                    .call(given_string, given_index, counts: given_counts)

        assert { result_string == given_string }
        assert { result_index  == given_index }
        assert { result_counts == given_counts }
      end

      group 'if the matcher returns truthy' do
        assert 'returns instance of the given class' do
          given_class = Class.new { def initialize *_; end }

          MatchWrapper.new(given_class, proc { true })
                      .call('')
                      .is_a?(given_class)
        end

        assert 'returned object is initialized with the result of the matcher' do
          result = 'Hey there little mouse'

          MatchWrapper.new(MockResult, proc { result })
                      .call('')
                      .content == [result]
        end

        assert 'result of the matcher is splatted into the result' do
          result = MockArray.new(1, 2, 3)

          MatchWrapper.new(MockResult, proc { result })
                      .call('')
                      .content == [1, 2, 3]
        end

        group 'passes metadata into result' do
          [:name, :temp].each do |key|
            group key do
              assert 'defaults to falsy' do
                !MatchWrapper.new(MockResult, proc { 'a match' })
                             .call('')
                             .metadata[key]
              end

              assert 'returns value given at init' do
                value     = :gretta
                init_hash = { key => value }

                MatchWrapper.new(MockResult, proc { 'a match' }, **init_hash)
                            .call('')
                            .metadata[key] == value
              end
            end
          end
        end

        group 'extends result class if defs given' do
          given_class = MockResult
          wrapper     = MatchWrapper.new(
                          MockResult,
                          proc { true },
                          defs: proc do
                                  def returns_something
                                    :something
                                  end
                                end
                        )

          assert do
            wrapper.call('').returns_something == :something
          end

          assert 'extension only applies inside the MatchWrapper' do
            !given_class.method_defined?(:returns_something)
          end
        end

        assert 'updates the counts hash with the length of the match if there is a name' do
          counts_hash = {}
          result      = 'flabble-d-doop'
          name        = :hey_hey_hey

          MatchWrapper.new(MockResult, proc { result }, name: name)
                      .call('', counts: counts_hash)

          counts_hash[name] == result.size
        end
      end

      group 'if the matcher returns' do
        with_falsy do |falsy|
          given_index  = 'Snorlax'
          given_string = 222

          mismatch_result = MatchWrapper.new(MockResult, proc { falsy })
                                        .call(given_string, given_index)

          assert 'returns instance of Mismatch' do
            mismatch_result.is_a?(Mismatch)
          end

          group 'Mismatch is given the string and index' do
            assert { mismatch_result.content == given_string }
            assert { mismatch_result.index   == given_index  }
          end
        end
      end

      assert 'if the matcher returns a Mismatch, returns the same Mismatch' do
        mismatch = Mismatch.new

        MatchWrapper.new(MockResult, proc { mismatch })
                    .call('')
                    .equal?(mismatch)
      end
    end
  end
end
