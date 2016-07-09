# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  class FutureWrapper
    def initialize key, hash, defs: nil, new_name: nil
      @key      = key
      @hash     = hash
      @defs     = defs
      @new_name = new_name
    end

    def rename new_name
      self.class.new(@key, @hash, defs: @defs, new_name: new_name)
    end

    def call *args
      unless @matcher
        @matcher = @hash.fetch(@key)
        @matcher = @matcher.rename(@new_name) if @new_name
      end

      @matcher.call(*args)
              .tap do |result|
                result.singleton_class.class_eval(&@defs) if @defs
              end
    end
  end
end
