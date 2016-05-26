# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  module Build
    module_function

    def matcher_return return_class, pattern_matcher
      lambda do |string, index = 0|
        found = pattern_matcher.call(string, index)

        if found.is_a?(Mismatch)
          found
        elsif found
          return_class.new(*found)
        else
          Mismatch.new(string, index)
        end
      end
    end

    def regexp_matcher regexp
      lambda do |string, index = 0|
        found  = regexp.match(string, index)
        string = found.to_s

        string if found && found.begin(0) == index && !string.empty?
      end
    end

    def pattern_matcher *pattern
      lambda do |string, index = 0|
        result = pattern.inject([]) do |memo, part|
                   match = part.call(string, index)

                   if valid_match? match
                     index += match.size
                     memo  << match
                   else
                     return match
                   end
                 end

        result unless result.empty? || result.all?(&:empty?)
      end
    end

    def maybe_matcher *pattern
      sub_matcher = pattern_matcher *pattern

      lambda do |string, index = 0|
        match = sub_matcher.call(string, index)

        if valid_match? match
          match
        else
          []
        end
      end
    end

    def either_matcher *pattern
      lambda do |string, index = 0|
        pattern.each do |matcher|
          match = matcher.call(string, index)

          return match if valid_nonempty_match? match
        end

        nil
      end
    end

    def repeat_matcher *pattern
      sub_matcher = matcher_return(SplatExpression, pattern_matcher(*pattern))

      lambda do |string, index = 0|
        result = []

        while valid_nonempty_match?(match = sub_matcher.call(string, index))
          index  += match.size
          result += match.to_a
        end

        result unless result.empty?
      end
    end

    def stored_proc hash, name
      proc { |*args| hash[name].call(*args) }
    end

    def valid_match? match
      match && !match.is_a?(Mismatch)
    end

    def valid_nonempty_match? match
      valid_match?(match) && !match.empty?
    end
  end
end
