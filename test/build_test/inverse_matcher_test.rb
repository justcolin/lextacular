# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../../build'
require_relative '../helpers/with_falsy_and_mismatch'

module Lextacular
  module Build
    group '.inverse_matcher' do
      example = 'skiffle scuffle'

      group 'matches string when' do
        group 'one of the matchers returns' do
          with_falsy_and_mismatch do |result|
            assert do
              inverse_matcher(regexp_matcher(/sk/), proc { result })
                             .call(example) == example
            end
          end
        end

        assert 'not all of the given matchers match' do
          inverse_matcher(regexp_matcher(/skiffle/), regexp_matcher(/-/))
                         .call(example) == example
        end

        assert 'given an index past a match' do
          inverse_matcher(regexp_matcher(/ /))
                         .call(example, 8) == 'scuffle'
        end
      end

      group 'does not match when' do
        assert 'string starts with a match' do
          !inverse_matcher(regexp_matcher(/s/))
                          .call(example)
        end

        assert 'the whole pattern matches' do
          !inverse_matcher(regexp_matcher(/s/), regexp_matcher(/k/))
                          .call(example)
        end

        assert 'given the index of a match' do
          !inverse_matcher(regexp_matcher(/ /), regexp_matcher(/scuffle/))
                          .call(example, 7)
        end
      end
    end
  end
end
