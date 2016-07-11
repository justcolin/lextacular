# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  module Falsy
    private

    # Check that two objects are either equal or are both falsy.
    def falsy_or_equal? first, second
      (!first && !second) || first == second
    end
  end
end
