# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './tet'
require_relative '../token'
require_relative '../expression'

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
    nested_expression = klass.new(
                          expression,
                          Lextacular::Token.new(content_3)
                        )

    group '#to_s' do
      group 'returns the joined content of all the children' do
        assert { expression.to_s == content_1 + content_2 }
      end

      group 'works with nested groups' do
        assert { nested_expression.to_s == expression.to_s + content_3 }
      end

      group 'returns an empty string when initialized with nothing' do
        assert { empty_expression.to_s == '' }
      end
    end

    group '#size' do
      group 'returns the sum of the sizes of all the children' do
        assert { expression.size == content_1.size + content_2.size }
      end

      group 'works with nested groups' do
        assert { nested_expression.size == expression.size + content_3.size }
      end

      group 'returns 0 when initialized with nothing' do
        assert { empty_expression.size.zero? }
      end
    end

    group '#children' do
      group 'returns the children given when initialized' do
        assert { expression.children == expression_content }
      end
    end

    group '#==' do
      group 'returns true if self or a expression with the same content' do
        assert { expression == expression }
        assert { expression == klass.new(*expression_content) }
      end

      group 'returns false if given anything else' do
        deny { expression == klass.new('something else') }
        deny { expression == expression_content }
      end
    end

    yield expression, expression_content
  end
end

expression_like Lextacular::Expression do |expression, content|
  group 'can not have its content splatted' do
    assert { [*expression] == [expression] }
  end
end

expression_like Lextacular::TempExpression do |expression, content|
  group 'can have its content splatted' do
    assert { [*expression] == [*content] }
  end
end
