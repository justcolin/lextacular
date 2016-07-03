# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './each_works'

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
      assert 'returns the joined content of all the children' do
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

    group '#empty?' do
      assert 'returns truthy when size == 0' do
        empty_expression.empty?
      end

      assert 'returns falsy when size > 0' do
        !expression.empty?
      end
    end

    group '#children' do
      assert 'returns the children given when initialized' do
        expression.children == expression_content
      end
    end

    group '#==' do
      group 'returns true if self or a expression with the same content' do
        assert { expression == expression }
        assert { expression == klass.new(*expression_content) }
      end

      group 'returns false if given anything else' do
        assert { expression != klass.new('something else') }
        assert { expression != expression_content }
      end
    end

    assert 'includes Enumerable' do
      expression.class.ancestors.include?(Enumerable)
    end

    group '#each' do
      assert 'exists' do
        expression.respond_to?(:each)
      end

      group 'goes over each item' do
        each_works enumerable: expression, content: expression_content
      end

      assert 'returns Enumerator when not given a block' do
        expression.each.is_a?(Enumerator)
      end

      group 'returned Enumerator is valid' do
        each_works enumerable: expression.each, content: expression_content
      end
    end

    yield expression, expression_content
  end
end
