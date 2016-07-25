# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

require_relative './mismatch'
require_relative './match_wrapper'
require_relative './expression'

module Lextacular
  module Matchers
    module_function

    # Create a matcher Proc which tries to match a regular expression.
    def regexp_matcher regexp
      lambda do |string, index = 0, counts:|
        found         = regexp.match(string, index)
        result_string = found.to_s

        result_string if found &&
                         found.begin(0) == index &&
                         !result_string.empty?
      end
    end

    # Create a matcher Proc which tries to match a series of matchers.
    def pattern_matcher *pattern
      lambda do |string, index = 0, counts:|
        original_counts = counts.dup

        pattern.inject([]) do |memo, part|
          found = part.call(string, index, counts: counts)

          if match? found
            index += found.size
            memo.push(*found)
          else
            counts.replace(original_counts)
            return found
          end
        end
      end
    end

    # Same as a pattern_matcher, but returns a valid/empty result if the pattern
    # does not match.
    def maybe_matcher *pattern
      submatcher = pattern_matcher(*pattern)

      lambda do |string, index = 0, counts:|
        found = submatcher.call(string, index, counts: counts)

        match?(found) ? found : []
      end
    end

    # Create a matcher Proc which returns the result of the first matcher in the
    # pattern which returns a valid match.
    def either_matcher *pattern
      lambda do |string, index = 0, counts:|
        original_counts = counts.dup

        pattern.each do |matcher|
          found = matcher.call(string, index, counts: counts)

          if match? found
            return found
          else
            counts.replace(original_counts)
          end
        end

        nil
      end
    end

    # Create a matcher Proc that runs over and over again until a matcher in the
    # pattern does not match.
    def repeat_matcher *pattern
      submatcher = MatchWrapper.new(pattern_matcher(*pattern), SplatExpression)

      lambda do |string, index = 0, counts:|
        result = []

        while nonempty_match?(found = submatcher.call(string, index, counts: counts))
          index += found.size
          result.push(*found)
        end

        result unless result.empty?
      end
    end

    # Create a matcher proc which walks across the string until it finds a point
    # where the given pattern matches.
    def inverse_matcher *pattern
      submatcher = MatchWrapper.new(pattern_matcher(*pattern), SplatExpression)

      lambda do |string, index = 0, counts:|
        starting_index = index
        size           = string.size

        index += 1 while index < size &&
                         !nonempty_match?(submatcher.call(string, index, counts: counts))

        string[starting_index..(index-1)] unless starting_index == index
      end
    end

    # Create a pattern matcher which creates a new context for counts
    def context_setter *pattern
      submatcher = pattern_matcher(*pattern)

      lambda do |string, index = 0, counts:|
        counts.push_context

        submatcher.call(string, index, counts: counts)
                  .tap { counts.pop_context }
      end
    end

    # Wrap a pattern matcher so match lengths can be recorded in the counts hash
    def count_setter submatcher
      lambda do |string, index = 0, counts:|
        submatcher.call(string, index, counts: counts)
                  .tap do |result|
                    counts[result.name] = result.size if match? result
                  end
      end
    end

    # Wrap a pattern matcher so it only returns a match if a comparison between
    # the matches length and the counts hash returns true.
    def count_matcher submatcher, method
      lambda do |string, index = 0, counts:|
        result = submatcher.call(string, index, counts: counts)

        result if !Matchers.match?(result) ||
                   result.size.send(method, counts[result.name])
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
