# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt
# (located in root directory of this project) for details.

def match_result_basics klass
  group '#==' do
    group 'returns true' do
      assert 'if given self' do
        token = klass.new
        token == token
      end

      assert 'if given a #{klass} with the same content' do
        content = 'here is some content'
        klass.new(content) == klass.new(content)
      end

      group 'treats nil and false as the same' do
        assert 'for name' do
          klass.new('', name: nil) == klass.new('', name: false)
        end

        assert 'for temp' do
          klass.new('', temp: nil) == klass.new('', temp: false)
        end
      end
    end

    group 'returns false' do
      assert 'if the name is different' do
        klass.new(name: :red) != klass.new(name: :blue)
      end

      assert 'if the temp status is different' do
        klass.new(temp: true) != klass.new(temp: false)
      end

      assert 'if given different content' do
        klass.new('something') != klass.new('something else')
      end

      assert 'if the class is different' do
        content = 'here is some text'
        klass.new(content) != content
      end
    end
  end

  group '#name' do
    assert 'defaults to falsy' do
      !klass.new.name
    end

    assert 'uses value giving at init' do
      name = :erica
      klass.new(name: name).name == name
    end
  end

  group '#temp' do
    assert 'defaults to falsy' do
      !klass.new.temp
    end

    assert 'uses value giving at init' do
      klass.new(temp: true).temp == true
    end
  end
end
