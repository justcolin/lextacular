# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  class Counts
    def initialize
      @hash = Hash.new { |hash, key| hash[key] = [] }
    end

    def [] key
      @hash[key].compact.last || -1
    end

    def []= key, value
      array = @hash[key]

      array.pop
      array.push(value)
    end

    def pop_context
      @hash.each_value(&:pop)

      self
    end

    def push_context
      @hash.each_value { |array| array << nil }

      self
    end
  end
end
