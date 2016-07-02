# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require '../build'

module Lextacular
  module Build
    group '.delay_pattern' do
      assert 'does not change items that are not Symbols' do
        initial = [proc {}, 42, {}, [], Object.new]
        result  = delay_pattern(initial, {})

        initial.zip(result).all? { |pair| pair.first == pair.last }
      end

      assert 'symbols get turned into stored procs' do
        hash    = {}
        delayed = delay_pattern([:one, :two, :three], hash)

        hash[:one]   = proc { 1 }
        hash[:two]   = proc { 2 }
        hash[:three] = proc { 3 }

        delayed.map(&:call).inject(:+) == 6
      end
    end
  end
end