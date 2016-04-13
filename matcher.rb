# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

module Lextacular
  module_function

  def build_matcher klass, pattern_matcher
    lambda do |string, index = 0|
      found = pattern_matcher.call(string, index)

      if found.is_a?(Mismatch)
        found
      elsif found
        klass.new(*found)
      else
        Mismatch.new(string, index)
      end
    end
  end

  def match_regexp regexp
    lambda do |string, index = 0|
      found = regexp.match(string)
      string = found.to_s

      string if found && found.begin(0) == index && !string.empty?
    end
  end

  def match_pattern *pattern
    lambda do |string, index = 0|
      pattern.inject([]) do |memo, part|
                result = part.call(string, index)

                if result.is_a?(Mismatch)
                  return result
                elsif result
                  index += result.size
                  memo  << result
                else
                  return
                end
              end
              .tap do |result|
                return if result.empty? || result.all?(&:empty?)
              end
    end
  end

  def match_maybe *pattern
    sub_matcher = match_pattern *pattern

    lambda do |string, index = 0|
      match = sub_matcher.call(string, index)

      if valid_match? match
        match
      else
        []
      end
    end
  end

  def match_either *pattern
    lambda do |string, index = 0|
      pattern.each do |matcher|
        match = matcher.call(string, index)

        return match if valid_nonempty_match? match
      end

      nil
    end
  end

  def match_repeat *pattern
    sub_matcher = build_matcher(TempExpression, match_pattern(*pattern))

    lambda do |string, index = 0|
      result = []

      while valid_nonempty_match? match = sub_matcher.call(string, index)
        index  += match.size
        result += match.to_a
      end

      result unless result.empty?
    end
  end

  def valid_match? match
    match && !match.is_a?(Mismatch)
  end

  def valid_nonempty_match? match
    valid_match?(match) && !match.empty?
  end
end
