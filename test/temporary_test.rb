# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative './decorator_like'
require_relative '../temporary'
require_relative '../Expression'

module Lextacular
  group Temporary do
    decorator_like Temporary

    group '#without_temps' do
      group 'if temporary returns nil' do
        assert { Temporary.new(42, true).without_temps.nil? }
      end

      group 'if not temporary' do
        group 'and contents are not enumerable returns content' do
          content = 'something'
          example = Temporary.new(content, false)

          assert { example.without_temps.equal?(content) }
        end

        group 'and contents are enumerable removes temporary children' do
          example = Temporary.new(
                      Expression.new(
                        Temporary.new(1, true),
                        Temporary.new(2, false),
                        Temporary.new(3, true),
                        Temporary.new(4, false)
                      ),
                      false
                    )

          assert { example.without_temps == Expression.new(2, 4) }
        end
      end
    end
  end
end
