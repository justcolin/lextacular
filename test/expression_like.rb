# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

def test_each enumerable:, content:
  matches = []
  index   = 0

  enumerable.each do |item|
    matches << (item == content[index])
    index += 1
  end

  assert { matches.all?(&:itself) }
end

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

    group 'includes Enumerable' do
      assert { expression.class.ancestors.include?(Enumerable) }
    end

    group '#each' do
      group 'exists' do
        assert { expression.respond_to? :each }
      end

      group 'goes over each item' do
        test_each enumerable: expression, content: expression_content
      end

      group 'returns Enumerator when not given a block' do
        assert { expression.each.is_a?(Enumerator) }
      end

      group 'returned Enumerator is valid' do
        test_each enumerable: expression.each, content: expression_content
      end
    end

    yield expression, expression_content
  end
end
