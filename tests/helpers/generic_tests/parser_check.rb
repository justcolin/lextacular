# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative '../../../mismatch'

def parser_check name, parser:, correct:, gives:, incorrect:, at:
  group name do
    assert 'returns valid parse tree with a valid string' do
      parser.parse(correct) == gives
    end

    err('errs when given an invalid string', expect: Lextacular::Mismatch) do
      parser.parse(incorrect)
    end

    assert 'err is at correct index' do
      begin
        parser.parse(incorrect)
        false
      rescue Lextacular::Mismatch => error
        error.index == at
      end
    end
  end
end
