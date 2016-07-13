# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require 'tet'
require_relative '../parser'
require_relative './helpers/parser_check'

module Lextacular
  group Parser do
    group 'rules' do
      parser_check(
        'can parse based on a regular expression',
        parser:    Parser.new { rule start: /hello/ },
        correct:   'hello',
        gives:     Token.new('hello', name: :start),
        incorrect: 'he', at: 0
      )

      parser_check(
        'can parse based on a series of regular expressions',
        parser:    Parser.new do
                     rule start:  [:first, :second, :third],
                          first:  /hello/,
                          second: /\s+/,
                          third:  /world/
                   end,
        correct:   'hello world',
        gives:     Expression.new(
                     Token.new('hello', name: :first),
                     Token.new(' ',     name: :second),
                     Token.new('world', name: :third),
                     name: :start
                   ),
        incorrect: 'hello-world', at: 5
      )

      parser_check(
        'can parse based on subexpressions',
        parser:    Parser.new do
                     rule start: [:first, :last],
                          first: [:one, :two],
                          last:  [:three, :four],
                          one:   /1/,
                          two:   /2/,
                          three: /3/,
                          four:  /4/
                   end,
        correct:   '1234',
        gives:     Expression.new(
                     Expression.new(
                       Token.new('1', name: :one),
                       Token.new('2', name: :two),
                       name: :first
                     ),
                     Expression.new(
                       Token.new('3', name: :three),
                       Token.new('4', name: :four),
                       name: :last
                     ),
                     name: :start
                   ),
        incorrect: '1237', at: 3
      )

      parser_check(
        'can alias expressions',
        parser:    Parser.new do
                     rule start: [:one],
                          one:   :uno,
                          uno:   /1/
                   end,
        correct:   '1',
        gives:     Expression.new(Token.new('1', name: :one), name: :start),
        incorrect: '2', at: 0
      )

      parser_check(
        'can have optional expressions',
        parser:    Parser.new do
                     rule start: [maybe(/a/, /b/), :last],
                          last:  maybe(:x, /Y/),
                          x:     /X/
                   end,
        correct:   'ab',
        gives:     Expression.new(
                     Token.new('a'),
                     Token.new('b'),
                     name: :start
                   ),
        incorrect: 'abX', at: 2
      )

      parser_check(
        'can repeat subexpressions',
        parser:    Parser.new do
                     rule start: [repeat(/a/, /b/), :last],
                          last:  repeat(/Y/, :z),
                          z:     /Z/
                   end,
        correct:   'ababYZ',
        gives:     Expression.new(
                     Token.new('a'), Token.new('b'),
                     Token.new('a'), Token.new('b'),
                     Token.new('Y'), Token.new('Z', name: :z),
                     name: :start
                   ),
        incorrect: 'abY', at: 2
      )

      parser_check(
        'can offer multiple alternative expressions',
        parser:    Parser.new do
                     rule start: [either(/a/, /b/, /c/), :last],
                          last:  either(/X/, :y, /Z/),
                          y:     /Y/
                   end,
        correct:   'aY',
        gives:     Expression.new(
                     Token.new('a'),
                     Token.new('Y', name: :y),
                     name: :start
                   ),
        incorrect: 'ba', at: 1
      )

      parser_check(
        'can splat subexpressions',
        parser:    Parser.new do
                     rule start: [splat(:one, :two), :last],
                          last:  splat(/3/, /4/),
                          one:   /1/,
                          two:   /2/
                   end,
        correct:   '1234',
        gives:     Expression.new(
                     Token.new('1', name: :one), Token.new('2', name: :two),
                     Token.new('3'), Token.new('4'),
                     name: :start
                   ),
        incorrect: '1237', at: 3
      )

      parser_check(
        'can make temporary subexpressions',
        parser:    Parser.new do
                     rule start:      [temp(/\(/), /secret/, :temp_close],
                          temp_close: temp(:close),
                          close:      /\)/
                   end,
        correct:   '(secret)',
        gives:     Expression.new(Token.new('secret'), name: :start),
        incorrect: 'secret', at: 0
      )

      parser_check(
        'can make inverse subexpressions',
        parser:    Parser.new do
                     rule start:     [
                                       temp(/\(/),
                                       :not_space, temp(:space), isnt(/\)/),
                                       temp(/\)/)
                                     ],
                          not_space: isnt(:space),
                          space:     / /
                   end,
        correct:   '(foo bar)',
        gives:     Expression.new(
                     Token.new('foo', name: :not_space),
                     Token.new('bar'),
                     name: :start
                   ),
        incorrect: '(foo )', at: 5
      )

      parser_check(
        'nest special sub expressions',
        parser:    Parser.new do
                     rule start: repeat(
                                   either(
                                     splat(/a/, temp(/b/)),
                                     temp(isnt(/\w/)),
                                     splat(/1/, temp(/2/))
                                   )
                                 )
                   end,
        correct:   '12+ab-ab::12',
        gives:     SplatExpression.new(
                     Token.new('1'),
                     Token.new('a'),
                     Token.new('a'),
                     Token.new('1'),
                     name: :start
                   ),
        incorrect: '121', at: 2
      )
    end

    assert 'result objects can have methods added to them' do
      Parser.new do
              rule start: /hello/ do
                def return_5
                  5
                end
              end
            end
            .parse('hello')
            .return_5 == 5
    end

    group 'aliases can have methods added to them' do
      result = Parser.new do
                 rule start: splat(:one, :uno),
                      uno:   /1/

                 rule one: :uno do
                   def return_5
                     5
                   end
                 end
               end
               .parse('11')
               .to_a

      assert { result.first.return_5 == 5 }
      err(expect: NoMethodError) { result.last.return_5 }
    end
  end
end
