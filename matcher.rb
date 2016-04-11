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

      if found
        klass.new(*found)
      else
        Mismatch.new(string, index)
      end
    end
  end

  def match_regexp regexp
    lambda do |string, index = 0|
      found = regexp.match(string)

      found.to_s if found && found.begin(0) == index
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
          memo << result
        else
          return
        end
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
    lambda do |string, index = nil|
      pattern.each do |matcher|
        match = matcher.call(string, index)

        return match if valid_match? match
      end

      nil
    end
  end

  def valid_match? match
    match && !match.is_a?(Mismatch)
  end
end
