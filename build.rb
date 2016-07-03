# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './mismatch'
require_relative './match_metadata'

module Lextacular
  module Build
    module_function

    def matcher_return return_class, pattern_matcher, name: nil, temp: nil
      return_class = Class.new(return_class) do
                       include MatchMetadata

                       define_method :initialize do |*args|
                         super *args

                         @name = name
                         @temp = temp
                       end
                     end

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

                   if match? match
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
      submatcher = pattern_matcher(*pattern)

      lambda do |string, index = 0|
        match = submatcher.call(string, index)

        if match? match
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

          return match if nonempty_match? match
        end

        nil
      end
    end

    def repeat_matcher *pattern
      submatcher = matcher_return(SplatExpression, pattern_matcher(*pattern))

      lambda do |string, index = 0|
        result = []

        while nonempty_match?(match = submatcher.call(string, index))
          index  += match.size
          result += match.to_a
        end

        result unless result.empty?
      end
    end

    def inverse_matcher *pattern
      submatcher = pattern_matcher(*pattern)

      lambda do |string, index = 0|
        starting_index = index
        size           = string.size

        while index < size && !nonempty_match?(submatcher.call(string, index))
          index += 1
        end

        unless starting_index == index
          string[starting_index..(index-1)]
        end
      end
    end

    def stored_proc name, hash
      proc { |*args| hash.fetch(name).call(*args) }
    end

    def delay_pattern pattern, hash
      pattern.map do |part|
        if part.is_a?(Symbol)
          stored_proc(part, hash)
        else
          part
        end
      end
    end

    def match? match
      match && !match.is_a?(Mismatch)
    end

    def nonempty_match? match
      match?(match) && !match.empty?
    end
  end
end
