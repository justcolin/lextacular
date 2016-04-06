# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

def assert
  begin
    if yield
      Tet.pass
    else
      Tet.fail
    end
  rescue StandardError => error
    Tet.error(error)
  end

  nil
end

def deny
  assert { !yield }
end

def err expect = StandardError
  begin
    yield
    Tet.no_error
  rescue StandardError => error
    if expect >= error.class
      true
    Tet.pass
    else
      Tet.wrong_error(expected: expect, got: error)
      false
    end
  end

  nil
end

def group name
  Tet.in_group(name) { yield }

  nil
end

module Tet
  @current_group = []
  @fail_messages = []
  @total_asserts = 0

  class << self
    def in_group name
      @current_group.push(name)
      yield
      @current_group.pop
    end

    def pass
      print '.'

      @total_asserts +=1
    end

    def fail message = '', letter = 'F'
      print letter

      @total_asserts +=1
      @fail_messages << @current_group.join('  :  ') + message
    end

    def error error
      fail format_error(error), '!'
    end

    def no_error
      fail indent("EXPECTED ERROR", 1)
    end

    def wrong_error expected:, got:
      fail indent("EXPECTED: #{expected}", 1) + format_error(got)
    end

    private

    def format_error error
      indent("ERROR: (#{error.class}) #{error.message}", 1) +
      indent(error.backtrace.join("\n"), 2)
    end

    def indent string, amount = 0
      string.split(/\n|\A/)
            .inject('') do |memo, line|
              memo + "\n" + ('    ' * amount) + line
            end
    end
  end

  at_exit do
    puts "\n#{@fail_messages.size} out of #{@total_asserts} failed"+
         indent(@fail_messages.join("\n\n"), 1)
  end
end
