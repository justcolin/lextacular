# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../match_wrapper'
require_relative '../counts'
require_relative './helpers/with_falsy'
require_relative './helpers/mocks/mock_result'
require_relative './helpers/mocks/mock_matcher'
require_relative './helpers/mocks/mock_temp'

module Lextacular
  group MatchWrapper do
    group '#==' do
      wrapper = MockResult
      matcher = MockMatcher.new
      name    = :a
      temp    = true
      defs    = proc {}

      example = MatchWrapper.new(
                  matcher,
                  wrapper,
                  name: name,
                  temp: temp,
                  defs: defs
                )

      group 'returns true when given values are the same' do
        assert do
          example == MatchWrapper.new(
                       matcher,
                       wrapper,
                       name: name,
                       temp: temp,
                       defs: defs
                     )
        end

        group 'treats nil and false as the same' do
          assert 'name' do
            MatchWrapper.new(matcher, wrapper, name: false, temp: temp, defs: defs) ==
            MatchWrapper.new(matcher, wrapper, name: nil,   temp: temp, defs: defs)
          end

          assert 'temp' do
            MatchWrapper.new(matcher, wrapper, name: name, temp: false, defs: defs) ==
            MatchWrapper.new(matcher, wrapper, name: name, temp: nil,   defs: defs)
          end

          assert 'defs' do
            MatchWrapper.new(matcher, wrapper, name: name, temp: temp, defs: false) ==
            MatchWrapper.new(matcher, wrapper, name: name, temp: temp, defs: nil)
          end
        end
      end

      group 'returns false when any value is changed' do
        assert 'class' do
          example != MatchWrapper.new(
                       matcher,
                       Class.new,
                       name: name,
                       temp: temp,
                       defs: defs
                     )
        end

        assert 'matcher' do
          example != MatchWrapper.new(
                       nil,
                       wrapper,
                       name: name,
                       temp: temp,
                       defs: defs
                     )
        end

        assert 'name' do
          example != MatchWrapper.new(
                       matcher,
                       wrapper,
                       name: nil,
                       temp: temp,
                       defs: defs
                     )
        end

        assert 'temp' do
          example != MatchWrapper.new(
                       matcher,
                       wrapper,
                       name: name,
                       temp: nil,
                       defs: defs
                     )
        end

        assert 'defs' do
          example != MatchWrapper.new(
                       matcher,
                       wrapper,
                       name: name,
                       temp: temp,
                       defs: nil
                     )
        end
      end
    end

    group '#rename' do
      result_class = MockResult
      original     = MatchWrapper.new(
                       MockMatcher.new,
                       result_class,
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
        renamed.call('', counts: Counts.new).returns_stuff == :stuff
      end

      assert 'returns the same result, but with a new name' do
        renamed_result  = renamed.call('', counts: Counts.new)
        original_result = original.call('', counts: Counts.new)

        assert { renamed_result.is_a?(result_class) }
        assert { original_result.is_a?(result_class) }
        assert { renamed_result.content == original_result.content }
        assert { renamed_result.temp    == original_result.temp }
        assert { renamed_result.name    == new_name }
      end
    end

    group '#call' do
      assert 'arguments are passed into the given matcher' do
        string  = 'Sugar Plum Fairy'
        index   = 32
        counts  = Counts.new
        matcher = MockMatcher.new

        MatchWrapper.new(matcher, MockResult)
                    .call(string, index, counts: counts)

        matcher.given?(string, index, counts)
      end

      group 'if the matcher returns truthy' do
        assert 'returns instance of the given class' do
          given_class = MockResult

          MatchWrapper.new(MockMatcher.new, given_class)
                      .call('', counts: Counts.new)
                      .is_a?(given_class)
        end

        assert 'returns whatever the matcher returned if no class was given' do
          matcher = MockMatcher.new
          result  = MatchWrapper.new(matcher)
                                .call('', counts: Counts.new)

          result == matcher.result
        end

        assert 'returned object is initialized with the result of the matcher' do
          result = 'Hey there little mouse'

          MatchWrapper.new(MockMatcher.new(result), MockResult)
                      .call('', counts: Counts.new)
                      .content == [result]
        end

        assert 'result of the matcher is splatted into the result' do
          array = [1, 2, 3]

          MatchWrapper.new(MockMatcher.new(MockArrayResult.new(*array)), MockResult)
                      .call('', counts: Counts.new)
                      .content == array
        end

        group 'passes metadata into result' do
          [:name, :temp].each do |key|
            group key do
              assert 'defaults to falsy' do
                !MatchWrapper.new(MockMatcher.new, MockResult)
                             .call('', counts: Counts.new)
                             .send(key)
              end

              assert 'returns value given at init' do
                value     = :gretta
                init_hash = { key => value }

                MatchWrapper.new(MockMatcher.new, MockResult, **init_hash)
                            .call('', counts: Counts.new)
                            .send(key) == value
              end
            end
          end
        end

        group 'extends result class if defs given' do
          given_class = MockResult
          wrapper     = MatchWrapper.new(
                          MockMatcher.new,
                          MockResult,
                          defs: proc do
                                  def returns_something
                                    :something
                                  end
                                end
                        )

          assert do
            wrapper.call('', counts: Counts.new).returns_something == :something
          end

          assert 'extension only applies inside the MatchWrapper' do
            !given_class.method_defined?(:returns_something)
          end
        end
      end

      group 'if the matcher returns' do
        with_falsy do |falsy|
          given_index  = 'Snorlax'
          given_string = 222

          mismatch_result = MatchWrapper.new(MockMatcher.new(falsy), MockResult)
                                        .call(given_string, given_index, counts: Counts.new)

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

        MatchWrapper.new(MockMatcher.new(mismatch), MockResult)
                    .call('', counts: Counts.new)
                    .equal?(mismatch)
      end
    end
  end
end
