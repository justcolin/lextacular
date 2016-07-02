# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

def each_works enumerable:, content:
  matches = []
  index   = 0

  enumerable.each do |item|
    matches << (item == content[index])
    index += 1
  end

  assert { matches.all?(&:itself) }
end
