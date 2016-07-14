# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './token'
require_relative './expression'
require_relative './match_wrapper'
require_relative './future_wrapper'
require_relative './matchers'

module Lextacular
  # A little sugar to make creating parsers more pleasant.
  def self.parser &block
    Parser.new(&block)
  end

  # A class that composes the rest of Lextacular into an easy to use interface.
  class Parser
    # Create a new parser and sets all the rules via the given block.
    def initialize &rule_defs
      @rules = {}

      instance_eval &rule_defs
    end

    # Parse the given string, raising an error if no match is found.
    def parse string
      result = @rules.fetch(:start).call(string)

      if Matchers.match?(result)
        if result.size == string.size
          return result.without_temps
        else
          result = Mismatch.new(string, result.size)
        end
      end

      raise result
    end

    private

    # Create new rules using the given patterns or names.
    def rule **new_rules, &defs
      new_rules.each do |name, pattern|
                 @rules[name] = translate(pattern, defs).rename(name)
               end
               .keys
    end

    # Translate the given pattern into a valid matcher.
    def translate item, defs = nil
      case item
      when Symbol
        FutureWrapper.new(item, @rules, defs: defs)
      when Array
        MatchWrapper.new(
          Expression,
          Matchers.pattern_matcher(*item.map { |part| translate(part) }),
          defs: defs
        )
      when Regexp
        MatchWrapper.new(Token, Matchers.regexp_matcher(item), defs: defs)
      else
        item
      end
    end

    # Defines a helper method which creates a special matcher.
    def self.def_helper name, use:, result:, temp: false
      define_method name do |*pattern|
        MatchWrapper.new(
          result,
          Matchers.send(
            use,
            *pattern.map { |part| translate(part) }
          ),
          temp: temp
        )
      end
    end

    # Create all the helper methods.

    def_helper :maybe,
               use:    :maybe_matcher,
               result: SplatExpression

    def_helper :repeat,
               use:    :repeat_matcher,
               result: SplatExpression

    def_helper :either,
               use:    :either_matcher,
               result: SplatExpression

    def_helper :splat,
               use:    :pattern_matcher,
               result: SplatExpression

    def_helper :temp,
               use:    :pattern_matcher,
               result: Expression,
               temp:   true

    def_helper :isnt,
               use:    :inverse_matcher,
               result: Token
  end
end
