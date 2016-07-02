# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './temporary'
require_relative './token'
require_relative './expression'
require_relative './build'

module Lextacular
  class Parser
    def initialize &rule_defs
      @rules = {}

      temp_expression new_lines: [maybe(repeat(:new_line, :spaces)), :new_line]
      temp_token      spaces:    /[ \t]+/,
                      new_line:  /\n/

      instance_eval &rule_defs
    end

    def parse string
      @rules.fetch(:start).call(string)
    end

    def self.rule_method method_name, result:, use:, temp: false
      define_method method_name do |**rules, &class_def|
        result = Temporary.new(
                   class_def ? Class.new(result, &class_def) : result,
                   temp
                 )

        rules.each do |name, pattern|
          if pattern.is_a?(Array)
            pattern = pattern.map do |part|
                        if part.is_a?(Symbol)
                          Build.stored_proc(part, @rules)
                        else
                          part
                        end
                      end
          end

          @rules[name] = Build.matcher_return(
                           result,
                           Build.send(use, *pattern)
                         )
        end

        self
      end
    end

    rule_method :token,
                result: Token,
                use:    :regexp_matcher

    rule_method :temp_token,
                result: Token,
                use:    :regexp_matcher,
                temp:   true

    rule_method :expression,
                result: Expression,
                use:    :pattern_matcher

    rule_method :temp_expression,
                result: Expression,
                use:    :pattern_matcher,
                temp:   true

    rule_method :splat_expression,
                result: SplatExpression,
                use:    :pattern_matcher

    def self.special_rule name, use
      define_method name do |*pattern|
        Build.matcher_return(
          Temporary.new(SplatExpression),
          Build.send(use, *pattern)
        )
      end
    end

    special_rule :maybe,  :maybe_matcher
    special_rule :repeat, :repeat_matcher
    special_rule :either, :either_matcher
    special_rule :isnt,   :inverse_matcher
  end
end


