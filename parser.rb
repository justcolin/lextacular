# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './token'
require_relative './expression'
require_relative './build'

module Lextacular
  class Parser
    def initialize &rule_defs
      @rules = {}

      instance_eval &rule_defs
    end

    def parse string
      result = @rules.fetch(:start).call(string)

      if Build.match?(result) && result.size == string.size
        result.without_temps
      else
        raise result
      end
    end

    def self.def_helper_method name, use
      define_method name do |*pattern|
        Build.matcher_return(
          SplatExpression,
          Build.send(
            use,
            *Build.delay_pattern(pattern, @rules)
          ),
          name: name
        )
      end
    end

    def_helper_method :maybe,  :maybe_matcher
    def_helper_method :repeat, :repeat_matcher
    def_helper_method :either, :either_matcher

    def self.def_rule_method method_name, result:, use:, temp: false
      define_method method_name do |**rules, &class_def|
        result = class_def ? Class.new(result, &class_def) : result

        rules.each do |name, pattern|
          @rules[name] = Build.matcher_return(
                           result,
                           Build.send(
                             use,
                             *Build.delay_pattern(pattern, @rules)
                           ),
                           temp: temp,
                           name: name
                         )
        end

        self
      end
    end

    def_rule_method :token,
                    result: Token,
                    use:    :regexp_matcher

    def_rule_method :not_token,
                    result: Token,
                    use:    :inverse_matcher

    def_rule_method :temp_token,
                    result: Token,
                    use:    :regexp_matcher,
                    temp:   true

    def_rule_method :expr,
                    result: Expression,
                    use:    :pattern_matcher

    def_rule_method :temp_expr,
                    result: Expression,
                    use:    :pattern_matcher,
                    temp:   true

    def_rule_method :splat_expr,
                    result: SplatExpression,
                    use:    :pattern_matcher
  end
end

s_expr_parser = Lextacular::Parser.new do
  expr start: [:s_expr]

  expr(s_expr: [:open, :inner_s_expr, :close]) do
    def to_s
      "[" + @children.join(' ') + "]"
    end
  end

  not_token(atom: either(:space, :open, :close)) do
    def to_s
      ":" + @content
    end
  end

  splat_expr inner_s_expr: repeat(:space?, either(:atom, :s_expr), :space?)
  temp_expr  space?:       maybe(:space)
  temp_token space:        /\s+/,
             open:         /\(/,
             close:        /\)/
end

require 'pp'

simple    = '(fizz)'
example   = '((hello world) and (fizz buzz))'
converted = '[[:hello :world] :and [:fizz :buzz]]'

pp s_expr_parser.parse(example).to_s == converted
