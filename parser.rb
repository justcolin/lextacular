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
      @rules.fetch(:start).call(string)
    end

    def self.def_helper_method name, use
      define_method name do |*pattern|
        Build.matcher_return(
          SplatExpression,
          Build.send(use, *pattern)
        )
      end
    end

    def_helper_method :maybe,  :maybe_matcher
    def_helper_method :repeat, :repeat_matcher
    def_helper_method :either, :either_matcher
    def_helper_method :isnt,   :inverse_matcher

    def self.def_rule_method method_name, result:, use:, temp: false
      define_method method_name do |**rules, &class_def|
        result = class_def ? Class.new(result, &class_def) : result

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
                           Build.send(use, *pattern),
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

    def_rule_method :temp_token,
                    result: Token,
                    use:    :regexp_matcher,
                    temp:   true

    def_rule_method :expression,
                    result: Expression,
                    use:    :pattern_matcher

    def_rule_method :temp_expression,
                    result: Expression,
                    use:    :pattern_matcher,
                    temp:   true

    def_rule_method :splat_expression,
                    result: SplatExpression,
                    use:    :pattern_matcher
  end
end
