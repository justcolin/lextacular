# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../match_wrapper'
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

      group 'returns true when given values are the same' do
        assert do
          MatchWrapper.new(wrapper, matcher, name: name, temp: temp) ==
          MatchWrapper.new(wrapper, matcher, name: name, temp: temp)
        end
      end

      group 'returns false when any value is changed' do
        assert do
          MatchWrapper.new(wrapper, matcher, name: name, temp: temp) !=
          MatchWrapper.new(nil,     matcher, name: name, temp: temp)
        end

        assert do
          MatchWrapper.new(wrapper, matcher, name: name, temp: temp) !=
          MatchWrapper.new(wrapper, nil,     name: name, temp: temp)
        end

        assert do
          MatchWrapper.new(wrapper, matcher, name: name, temp: temp) !=
          MatchWrapper.new(wrapper, matcher, name: nil,  temp: temp)
        end

        assert do
          MatchWrapper.new(wrapper, matcher, name: name, temp: temp) !=
          MatchWrapper.new(wrapper, matcher, name: name, temp: nil)
        end
      end
    end

    group '#rename' do
      original = MatchWrapper.new(MockResult, proc { "stuff" }, name: :Abe, temp: true)
      new_name = :Lincoln
      renamed  = original.rename(new_name)

      assert 'returns a MatchWrapper' do
        renamed.is_a?(MatchWrapper)
      end

      assert 'returns a different object' do
        !renamed.equal?(original)
      end

      assert 'returns the same result, but with a new name' do
        renamed_result  = renamed.call('')
        original_result = original.call('')

        assert { renamed_result.content         == original_result.content }
        assert { renamed_result.class           == original_result.class }
        assert { renamed_result.metadata[:name] == new_name }
        assert { renamed_result.metadata[:temp] == original_result.metadata[:temp] }
      end
    end

    group '#call' do
      group 'arguments are passed into the given matcher' do
        given_index  = 32
        given_string = 'Sugar Plum Fairy'

        result_string = nil
        result_index  = nil

        pattern_matcher = proc do |string, index|
                            result_string = string
                            result_index  = index
                          end

        MatchWrapper.new(MockResult, pattern_matcher)
                    .call(given_string, given_index)

        assert { result_string == given_string }
        assert { result_index  == given_index }
      end

      assert 'index argument defaults to 0' do
        result_index    = nil
        pattern_matcher = proc { |_, index| result_index = index }

         MatchWrapper.new(MockResult, pattern_matcher)
                     .call('here is a string to match')

        result_index.zero?
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
              assert 'defaults to nil' do
                MatchWrapper.new(MockResult, proc { true })
                              .call('')
                              .metadata[key].nil?
              end

              assert 'returns value given at init' do
                value     = :gretta
                init_hash = { key => value }

                MatchWrapper.new(MockResult, proc { true }, **init_hash)
                            .call('')
                            .metadata[key] == value
              end
            end
          end
        end
      end

      group 'if the matcher returns falsy' do
        given_index  = 'Snorlax'
        given_string = 222

        mismatch_result = MatchWrapper.new(MockResult, proc { nil })
                                      .call(given_string, given_index)

        assert 'returns instance of Mismatch' do
          mismatch_result.is_a?(Mismatch)
        end

        group 'Mismatch is given the string and index' do
          assert { mismatch_result.content == given_string }
          assert { mismatch_result.index   == given_index  }
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
