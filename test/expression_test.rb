# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require './tet'
require '../token'
require '../expression'

def expression_like klass
  group klass do
    content_1 = 'here is some text'
    content_2 = 'even more text!'
    content_3 = 'what?! more text?!'

    expression_content = [
                           Lextacular::Token.new(content_1),
                           Lextacular::Token.new(content_2)
                         ]

    empty_expression  = klass.new
    expression        = klass.new(*expression_content)
    nested_expression = klass.new(expression, content_3)

    group '#to_s' do
      assert 'returns the content of the children concatenated together' do
        expression.to_s == content_1 + content_2
      end

      assert 'works with nested groups' do
        nested_expression.to_s == expression.to_s + content_3
      end

      assert 'returns an empty string when initialized with nothing' do
        empty_expression.to_s == ''
      end
    end

    group '#size' do
      assert 'returns the sum of the sizes of all the children' do
        expression.size == content_1.size + content_2.size
      end

      assert 'works with nested groups' do
        nested_expression.size == expression.size + content_3.size
      end

      assert 'returns 0 when initialized with nothing' do
        empty_expression.size.zero?
      end
    end

    yield expression, expression_content
  end
end

expression_like Lextacular::Expression do |expression, content|
  assert 'can not have its content splatted' do
    [*expression] == [expression]
  end
end

expression_like Lextacular::TempExpression do |expression, content|
  assert 'can have its content splatted' do
    [*expression] == [*content]
  end
end
