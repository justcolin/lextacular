# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative './decorator_like'
require_relative '../temporary'

module Lextacular
  group Temporary do
    decorator_like Temporary

    group '#temp?' do
      assert 'normally returns true' do
        Temporary.new(Object).temp?
      end

      assert 'returns false if initialized with false' do
        !Temporary.new(Object, false).temp?
      end
    end
  end
end
