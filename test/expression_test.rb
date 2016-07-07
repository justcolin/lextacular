# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative './helpers/expression_basics'
require_relative '../token'
require_relative '../expression'

expression_basics Lextacular::Expression do |expression, content|
  assert 'can not have its content splatted' do
    [*expression] == [expression]
  end
end

expression_basics Lextacular::SplatExpression do |expression, content|
  assert 'can have its content splatted' do
    [*expression] == [*content]
  end
end
