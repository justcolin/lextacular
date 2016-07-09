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
require_relative './build'

module Lextacular
  class Parser
    def initialize &rule_defs
      @rules = {}

      instance_eval &rule_defs
    end

    def parse string
      result = @rules.fetch(:start).call(string)

      if Build.match?(result)
        if result.size == string.size
          return result.without_temps
        else
          result = Mismatch.new(string, result.size)
        end
      end

      raise result
    end

    def rule **new_rules, &defs
      new_rules.each do |name, pattern|
                 @rules[name] = translate(pattern, defs).rename(name)
               end
               .keys
    end

    def self.def_helper name, use:, result:, temp: false
      define_method name do |*pattern|
        MatchWrapper.new(
          result,
          Build.send(
            use,
            *pattern.map { |part| translate(part) }
          ),
          temp: temp
        )
      end
    end

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

    private

    def translate item, defs = nil
      case item
      when Symbol
        FutureWrapper.new(item, @rules, defs: defs)
      when Array
        MatchWrapper.new(
          Expression,
          Build.pattern_matcher(*item.map { |part| translate(part) }),
          defs: defs
        )
      when Regexp
        MatchWrapper.new(Token, Build.regexp_matcher(item), defs: defs)
      else
        item
      end
    end
  end
end
