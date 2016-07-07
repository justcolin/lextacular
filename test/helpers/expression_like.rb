# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './each_works'
require_relative './match_result_basics'

def expression_like klass
  group klass do
    match_result_basics klass

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

    group '#without_temps' do
      assert 'returns false if initialzed as temp' do
        !klass.new(temp: true).without_temps
      end

      assert 'returns new instance of class, filtering out temp children if not temp' do
        name     = :wilhelm
        children = [klass.new(temp: true), klass.new(temp: false), klass.new(temp: true)]
        filtered = children.map { |part| part.without_temps }.compact

        klass.new(*children, temp: false, name: name).without_temps ==
        klass.new(*filtered, temp: false, name: name)
      end

      assert 'temp defaults to falsy' do
        klass.new.without_temps
      end
    end

    yield expression, expression_content
  end
end
