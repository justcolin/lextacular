# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative './helpers/decorator_like'
require_relative '../decorator'

group Lextacular::Decorator do
  decorator_like Lextacular::Decorator
end
