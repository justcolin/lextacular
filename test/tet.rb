# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

TET_SEPERATOR = '  :  '
TET_GROUP     = []
TET_MESSAGES  = []

at_exit do
  if TET_MESSAGES.empty?
    puts " done!"
  else
    puts "\n\n" + TET_MESSAGES.unshift("Results:").join("\n\t")
  end
end

def fail_message message
  TET_MESSAGES << (TET_GROUP + [message]).join(TET_SEPERATOR)
end

def assert description, result: :none
  result = yield if result == :none

   if result
     print ?.
   else
     fail_message description
     print ?F
   end

  result
end

def deny description
  assert description, result: !yield
end

def err description, expect = StandardError
  result = false

  begin
    yield
    description += " (no error)"
  rescue StandardError => error
    if expect >= error.class
      result = true
    else
      description += " (expected #{expect}, got #{error.class})"
    end
  end

  assert description, result: result

  nil
end

def group name
  TET_GROUP.push(name.to_s)
  yield
  TET_GROUP.pop
end
