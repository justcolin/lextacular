# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  class Decorator < BasicObject
    def initialize object
      @object = object
      @class  = class << self
                  superclass
                end

      if @object.respond_to?(:new)
        class << self
          define_method :new do |*args|
            @class.new(@object.new(*args))
          end
        end
      end
    end

    def respond_to? method_name
      @class.instance_methods.include?(method_name) ||
      @object.respond_to?(method_name)
    end

    def method_missing method_name, *args, &block
      if @object.respond_to?(method_name)
        @object.send(method_name, *args, &block)
      else
        super
      end
    end
  end
end
