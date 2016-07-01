# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../build'

module Lextacular
  module Build
    group '.inverse_matcher' do
      example = 'skiffle scuffle'

      group 'matches string when' do
        group 'one of the matchers returns falsy' do
          matcher = inverse_matcher(proc { nil })

          assert { matcher.call(example) == example }
        end

        group 'one of the matchers returns a Mismatch' do
          matcher = inverse_matcher(proc { Mismatch.new })

          assert { matcher.call(example) == example }
        end

        group 'not all of the given matchers match' do
          matcher = inverse_matcher(
                      regexp_matcher(/skiffle/),
                      regexp_matcher(/-/),
                    )

          assert { matcher.call(example) == example }
        end

        group 'given an index past a match' do
          matcher = inverse_matcher(regexp_matcher(/ /))

          assert { matcher.call(example, 8) == 'scuffle' }
        end
      end

      group 'does not match when' do
        group 'string starts with a match' do
          matcher = inverse_matcher(regexp_matcher(/s/))

          assert { !matcher.call(example) }
        end

        group 'the whole pattern matches' do
          matcher = inverse_matcher(
                      regexp_matcher(/s/),
                      regexp_matcher(/k/),
                      regexp_matcher(/i/)
                    )

          assert { !matcher.call(example) }
        end

        group 'given the index of a match' do
          matcher = inverse_matcher(
                      regexp_matcher(/ /),
                      regexp_matcher(/scuffle/)
                    )

          assert { !matcher.call(example, 7) }
        end
      end
    end
  end
end
