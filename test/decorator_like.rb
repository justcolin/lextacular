# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

def decorator_like klass
  example_class = Class.new(klass) do
                    def example_method
                      true
                    end
                  end

  assert 'forwards method calls to the object it wraps' do
    example_class.new('42').to_i == 42
  end

  err 'errs if the wrapped object is missing method', expect: NameError do
    example_class.new('thingy').to_flumblederp
  end

  assert 'passes arguments to forwarded method' do
    example_class.new('W').ljust(2) == 'W '
  end

  assert 'passes block to forwarded method' do
    example_class.new([1,2,3]).reject(&:odd?) == [2]
  end

  group '#new' do
    wrapped_class = Hash
    example       = example_class.new(Hash).new

    assert "returns another #{example_class}" do
      example.example_method
    end

    assert 'wraps a new instance of the wrapped class' do
      example.is_a?(wrapped_class)
    end
  end

  group '#respond_to?' do
    example = example_class.new(Hash.new)

    assert 'Checks wrapped object' do
      example.respond_to?(:[])
    end

    assert "first checks #{example_class} instance" do
      example.respond_to?(:example_method)
    end
  end
end
