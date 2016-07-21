# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../helpers/pattern_matcher_basics'
require_relative '../../matchers'
require_relative '../../counts'

module Lextacular
  module Matchers
    group '.context_matcher' do
      pattern_matcher_basics method(:context_matcher), preserves_count: false

      group 'passes counts between children' do
        counts   = Counts.new
        key      = :test_item
        value_1  = 4
        value_2  = 12
        value_3  = 1
        result_1 = nil
        result_2 = nil

        counts[key] = value_1

        context_matcher(
                         proc do |counts:|
                           result_1    = counts[key]
                           counts[key] = value_2
                         end,
                         proc do |counts:|
                           result_2    = counts[key]
                           counts[key] = value_3
                         end
                       )
                       .call('', counts: counts)

        assert { result_1 == value_1 }
        assert { result_2 == value_2 }
      end

      group 'resets counts after running the pattern' do
        counts = Counts.new
        key    = :something
        value  = 872

        counts[key] = value

        context_matcher(proc { |counts:| counts[key] = value + 1 })
                       .call('', counts: counts)

        assert { counts[key] == value }
      end
    end
  end
end
