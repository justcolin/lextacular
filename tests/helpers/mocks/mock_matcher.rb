# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

class MockMatcher
  Unset = Object.new

  attr_reader :result, :result_size, :given_string, :given_index, :given_counts

  def initialize result = Unset, &block
    @result = if result == Unset
                rand(1_000_000).to_s
              else
                result
              end

    @result_size = @result.size if @result.respond_to?(:size)
    @callback    = block
  end

  def call string, index = 0, counts:
    @callback.call(string, index, counts: counts) if @callback

    @given_string = string
    @given_index  = index
    @given_counts = counts

    @result
  end

  def given? string, index, counts
    @given_string == string
    @given_index  == index
    @given_counts == counts
  end
end
