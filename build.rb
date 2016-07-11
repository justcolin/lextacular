# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './mismatch'
require_relative './match_wrapper'

module Lextacular
  module Build
    module_function

    # Create a matcher Proc which tries to match a regular expression.
    def regexp_matcher regexp
      lambda do |string, index = 0|
        found         = regexp.match(string, index)
        result_string = found.to_s

        result_string if found &&
                         found.begin(0) == index &&
                         !result_string.empty?
      end
    end

    # Create a matcher Proc which tries to match a series of matchers.
    def pattern_matcher *pattern
      lambda do |string, index = 0|
        pattern.inject([]) do |memo, part|
          found = part.call(string, index)

          if match? found
            index += found.size
            memo.push(*found)
          else
            return found
          end
        end
      end
    end

    # Same as a pattern_matcher, but returns a valid/empty result if the pattern
    # does not match.
    def maybe_matcher *pattern
      submatcher = pattern_matcher(*pattern)

      lambda do |string, index = 0|
        found = submatcher.call(string, index)

        match?(found) ? found : []
      end
    end

    # Create a matcher Proc which returns the result of the first matcher in the
    # pattern which returns a valid match.
    def either_matcher *pattern
      lambda do |string, index = 0|
        pattern.each do |matcher|
          found = matcher.call(string, index)

          return found if match? found
        end

        nil
      end
    end

    # Create a matcher Proc that runs over and over again until a matcher in the
    # pattern does not match.
    def repeat_matcher *pattern
      submatcher = MatchWrapper.new(SplatExpression, pattern_matcher(*pattern))

      lambda do |string, index = 0|
        result = []

        while nonempty_match?(found = submatcher.call(string, index))
          index += found.size
          result.push(*found)
        end

        result unless result.empty?
      end
    end

    # Create a matcher proc which walks across the string until it finds a point
    # where the given pattern matches.
    def inverse_matcher *pattern
      submatcher = pattern_matcher(*pattern)

      lambda do |string, index = 0|
        starting_index = index
        size           = string.size

        index += 1 while index < size &&
                         !nonempty_match?(submatcher.call(string, index))

        string[starting_index..(index-1)] unless starting_index == index
      end
    end

    def match? found
      found && !found.is_a?(Mismatch)
    end

    def nonempty_match? found
      match?(found) && !found.empty?
    end
  end
end
