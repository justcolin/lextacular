# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

TET_DATA = Struct.new(:seperator, :group, :messages, :total, :failed)
                 .new(' : ',      [],     [],        0,      0)

at_exit do
  puts "\n" unless TET_DATA.total.zero?

  puts TET_DATA.messages
               .unshift("#{TET_DATA.failed} out of #{TET_DATA.total} failed")
               .join("\n\t")
end

def assert description
  TET_DATA.total += 1
  result     = begin
                 yield
               rescue StandardError => error
                 description << " (error)" <<
                                "\n\t\t" <<
                                error.to_s <<
                                "\n\t\t\t" <<
                                error.backtrace.join("\n\t\t\t") <<
                                "\n"
                 false
               end

  if result
    print '.'
  else
    TET_DATA.failed += 1
    TET_DATA.messages
            .push(
              TET_DATA.group.join(TET_DATA.seperator) +
              TET_DATA.seperator +
              description
            )

    print 'F'
  end

  result
end

def deny description
  assert(description) { !yield }
end

def err description, expect = StandardError
  result = false

  begin
    yield
    description += " (expected error)"
  rescue StandardError => error
    if expect >= error.class
      result = true
    else
      description += " (expected #{expect}, got #{error.class})"
    end
  end

  assert(description) { result }
end

def group name
  TET_DATA.group.push(name.to_s)
  yield
  TET_DATA.group.pop
end
