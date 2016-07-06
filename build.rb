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
                   found = part.call(string, index)

                   if match? found
                     index += found.size
                     memo.push(*found)
                   else
                     return found
                   end
                 end

        result
      end
    end

    def maybe_matcher *pattern
      submatcher = pattern_matcher(*pattern)

      lambda do |string, index = 0|
        found = submatcher.call(string, index)

        if match? found
          found
        else
          []
        end
      end
    end

    def either_matcher *pattern
      lambda do |string, index = 0|
        pattern.each do |matcher|
          found = matcher.call(string, index)

          # should this just use #match? instead?
          if nonempty_match? found
            return found
          else
            # Gather info on possible mismatches, maybe change #each to #inject
          end
        end

        nil
      end
    end

    def repeat_matcher *pattern
      submatcher = matcher_return(SplatExpression, pattern_matcher(*pattern))

      lambda do |string, index = 0|
        result = []

        # should this just use #match? instead?
        while nonempty_match?(found = submatcher.call(string, index))
          index  += found.size
          result += found.to_a
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
      if pattern.respond_to?(:to_a)
        pattern.to_a.map do |part|
          if part.is_a?(Symbol)
            stored_proc(part, hash)
          else
            part
          end
        end
      else
        pattern
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
