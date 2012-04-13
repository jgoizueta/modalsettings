require 'test_helper'

class SettingsTest < ActiveSupport::TestCase

  def test_simple_settings
    s = Settings[:a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3]]
    assert_equal 1, s.a
    assert_equal 1, s[:a]
    assert_equal 1, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']
    assert_nil s.z
    assert_nil s[:z]
    assert_nil s['z']

    s.a = 10
    assert_equal 10, s.a
    assert_equal 10, s[:a]
    assert_equal 10, s['a']

  end

  def test_nested_settings
    s = Settings[
      :a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3],
      :z=>{
        :a=>10, 'b'=>20, :x=>'rst', :y=>[10,20,30], :w=>{:a=>1000}
      }
    ]
    assert_equal 1, s.a
    assert_equal 1, s[:a]
    assert_equal 1, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']

    assert_equal 10, s.z.a
    assert_equal 10, s[:z].a
    assert_equal 10, s['z'].a
    assert_equal 10, s.z[:a]
    assert_equal 10, s[:z][:a]
    assert_equal 10, s['z'][:a]
    assert_equal 10, s.z['a']
    assert_equal 10, s[:z]['a']
    assert_equal 10, s['z']['a']
    assert_equal 20, s.z.b
    assert_equal 20, s.z[:b]
    assert_equal 20, s.z['b']
    assert_equal 'rst', s.z.x
    assert_equal 'rst', s.z[:x]
    assert_equal 'rst', s.z['x']
    assert_equal [10,20,30], s.z.y
    assert_equal [10,20,30], s.z[:y]
    assert_equal [10,20,30], s.z['y']
    assert_nil s.z.z
    assert_nil s.z[:z]
    assert_nil s.z['z']
    assert_equal 1000, s.z.w.a
    assert_equal 1000, s[:z].w.a
    assert_equal 1000, s['z'].w.a
    assert_equal 1000, s.z[:w].a
    assert_equal 1000, s.z['w'].a
  end

  def test_assignment
    s = Settings[:a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3], :z=>{:a=>100, :b=>200}]
    assert_equal 1, s.a
    assert_equal 1, s[:a]
    assert_equal 1, s['a']
    assert_equal 100, s.z.a
    assert_equal 100, s.z[:a]
    assert_equal 100, s.z['a']
    s.a = 10
    assert_equal 10, s.a
    assert_equal 10, s[:a]
    assert_equal 10, s['a']
    s[:a] = 11
    assert_equal 11, s.a
    assert_equal 11, s[:a]
    assert_equal 11, s['a']
    s['a'] = 12
    assert_equal 12, s.a
    assert_equal 12, s[:a]
    assert_equal 12, s['a']
    s.z.a = 101
    assert_equal 101, s.z.a
    assert_equal 101, s.z[:a]
    assert_equal 101, s.z['a']
    s.z[:a] = 102
    assert_equal 102, s.z.a
    assert_equal 102, s.z[:a]
    assert_equal 102, s.z['a']
    s.z['a'] = 103
    assert_equal 103, s.z.a
    assert_equal 103, s.z[:a]
    assert_equal 103, s.z['a']
  end

  def test_settings_merge
    s = Settings[:a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3]]
    s.merge! :a=>10, :z=>100
    assert_equal 10, s.a
    assert_equal 2, s.b
    assert_equal 100, s.z

    s = Settings[:a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3]]
    s.merge! Settings[:a=>10, :z=>100]
    assert_equal 10, s.a
    assert_equal 2, s.b
    assert_equal 100, s.z
  end

  def test_yaml_load
    File.open(fn=File.join(Rails.root, 'tmp', 'settings_test.yml'), 'w') do |file|
      file.write({:a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3]}.to_yaml)
    end
    s = Settings.load(fn)
    assert_equal 1, s.a
    assert_equal 1, s[:a]
    assert_equal 1, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']
    assert_nil s.z
    assert_nil s[:z]
    assert_nil s['z']
  end

  def test_yaml_erb_load
    yml = %{
      :a: <%= 30/3 %>
      b: <%= 1+1 %>
      :x: xyz
      :y: <%= (1..3).to_a.inspect %>
    }
    File.open(fn=File.join(Rails.root, 'tmp', 'settings_test.yml'), 'w') do |file|
      file.write yml
    end
    s = Settings.load(fn)
    assert_equal 10, s.a
    assert_equal 10, s[:a]
    assert_equal 10, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']
    assert_nil s.z
    assert_nil s[:z]
    assert_nil s['z']
  end

  def test_rails_env_merge
    yml = %{
      :a: <%= 30/3 %>
      b: <%= 1+1 %>
      :x: xyz
      :y: <%= (1..3).to_a.inspect %>
      test:
        a: 100
        z: 200
    }
    File.open(fn=File.join(Rails.root, 'tmp', 'settings_test.yml'), 'w') do |file|
      file.write yml
    end
    s = Settings.load(fn, 'test')
    assert_equal 100, s.a
    assert_equal 100, s[:a]
    assert_equal 100, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']
    assert_equal 200, s.z
    assert_equal 200, s[:z]
    assert_equal 200, s['z']
  end

  def test_to_hash
    s = Settings[:a=>1, 'b'=>2]
    h = s.to_h
    assert h.kind_of?(Hash)
    assert_equal 1, h[:a]
    assert_equal 2, h[:b]
    assert_equal [:a,:b], h.keys.sort_by(&:to_s)
  end

  def test_to_yaml
    s = Settings[:a=>1, 'b'=>2]
    h = YAML.load(s.to_yaml)
    assert h.kind_of?(Hash)
    assert_equal 1, h[:a]
    assert_equal 2, h[:b]
    assert_equal [:a,:b], h.keys.sort_by(&:to_s)
  end

  def test_assign_hash
    s = Settings[
      :a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3],
    ]
    s.z = { :a=>10, 'b'=>20, :x=>'rst', :y=>[10,20,30], :w=>{:a=>1000} }

    assert_equal 1, s.a
    assert_equal 1, s[:a]
    assert_equal 1, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']

    assert_equal 10, s.z.a
    assert_equal 10, s[:z].a
    assert_equal 10, s['z'].a
    assert_equal 10, s.z[:a]
    assert_equal 10, s[:z][:a]
    assert_equal 10, s['z'][:a]
    assert_equal 10, s.z['a']
    assert_equal 10, s[:z]['a']
    assert_equal 10, s['z']['a']
    assert_equal 20, s.z.b
    assert_equal 20, s.z[:b]
    assert_equal 20, s.z['b']
    assert_equal 'rst', s.z.x
    assert_equal 'rst', s.z[:x]
    assert_equal 'rst', s.z['x']
    assert_equal [10,20,30], s.z.y
    assert_equal [10,20,30], s.z[:y]
    assert_equal [10,20,30], s.z['y']
    assert_nil s.z.z
    assert_nil s.z[:z]
    assert_nil s.z['z']
    assert_equal 1000, s.z.w.a
    assert_equal 1000, s[:z].w.a
    assert_equal 1000, s['z'].w.a
    assert_equal 1000, s.z[:w].a
    assert_equal 1000, s.z['w'].a

    s = Settings[
      :a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3],
    ]
    s['z'] = { :a=>10, 'b'=>20, :x=>'rst', :y=>[10,20,30], :w=>{:a=>1000} }

    assert_equal 1, s.a
    assert_equal 1, s[:a]
    assert_equal 1, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']

    assert_equal 10, s.z.a
    assert_equal 10, s[:z].a
    assert_equal 10, s['z'].a
    assert_equal 10, s.z[:a]
    assert_equal 10, s[:z][:a]
    assert_equal 10, s['z'][:a]
    assert_equal 10, s.z['a']
    assert_equal 10, s[:z]['a']
    assert_equal 10, s['z']['a']
    assert_equal 20, s.z.b
    assert_equal 20, s.z[:b]
    assert_equal 20, s.z['b']
    assert_equal 'rst', s.z.x
    assert_equal 'rst', s.z[:x]
    assert_equal 'rst', s.z['x']
    assert_equal [10,20,30], s.z.y
    assert_equal [10,20,30], s.z[:y]
    assert_equal [10,20,30], s.z['y']
    assert_nil s.z.z
    assert_nil s.z[:z]
    assert_nil s.z['z']
    assert_equal 1000, s.z.w.a
    assert_equal 1000, s[:z].w.a
    assert_equal 1000, s['z'].w.a
    assert_equal 1000, s.z[:w].a
    assert_equal 1000, s.z['w'].a

    s = Settings[
      :a=>1, 'b'=>2, :x=>'xyz', :y=>[1,2,3],
    ]
    s[:z] = { :a=>10, 'b'=>20, :x=>'rst', :y=>[10,20,30], :w=>{:a=>1000} }

    assert_equal 1, s.a
    assert_equal 1, s[:a]
    assert_equal 1, s['a']
    assert_equal 2, s.b
    assert_equal 2, s[:b]
    assert_equal 2, s['b']
    assert_equal 'xyz', s.x
    assert_equal 'xyz', s[:x]
    assert_equal 'xyz', s['x']
    assert_equal [1,2,3], s.y
    assert_equal [1,2,3], s[:y]
    assert_equal [1,2,3], s['y']

    assert_equal 10, s.z.a
    assert_equal 10, s[:z].a
    assert_equal 10, s['z'].a
    assert_equal 10, s.z[:a]
    assert_equal 10, s[:z][:a]
    assert_equal 10, s['z'][:a]
    assert_equal 10, s.z['a']
    assert_equal 10, s[:z]['a']
    assert_equal 10, s['z']['a']
    assert_equal 20, s.z.b
    assert_equal 20, s.z[:b]
    assert_equal 20, s.z['b']
    assert_equal 'rst', s.z.x
    assert_equal 'rst', s.z[:x]
    assert_equal 'rst', s.z['x']
    assert_equal [10,20,30], s.z.y
    assert_equal [10,20,30], s.z[:y]
    assert_equal [10,20,30], s.z['y']
    assert_nil s.z.z
    assert_nil s.z[:z]
    assert_nil s.z['z']
    assert_equal 1000, s.z.w.a
    assert_equal 1000, s[:z].w.a
    assert_equal 1000, s['z'].w.a
    assert_equal 1000, s.z[:w].a
    assert_equal 1000, s.z['w'].a
  end

  def test_collisions
    s = Settings[:a => 10, :merge => 100]
    assert_equal [:merge], s.collisions
    assert_equal 100, s[:merge]
    s[:merge] = 200
    assert_equal 200, s['merge']
  end

  def test_recursive_collisions
    s = Settings[
      :a => 10, :merge => 100,
      :x=>{:a=>100, :b=>1},
      :y=>{:a=>100, :to_h=>200},
      :z=>{:a=>200, :w=>{:b=>1, :to_yaml=>300}}
    ]
    assert_equal [:merge], s.collisions
    assert_equal [:merge, [:y, :to_h], [:z, :w, :to_yaml]], s.collisions(true).sort_by{|k| Array(k).size}
    s = Settings[
      :a => 10, :merge => {:to_h=>200}
    ]
    assert_equal [:merge, [:merge, :to_h]], s.collisions(true).sort_by{|k| Array(k).size}
  end

  def test_deep_copy
    s = Settings[
      :a=>10,
      :b=>{
        :c=>20,
        :d=>{
          :e=>30,
          :f=> {
            :g=>40
          }
        }
      }
    ]
    d = s.dup
    assert_equal 10, d.a
    assert_equal 20, d.b.c
    assert_equal 30, d.b.d.e
    assert_equal 40, d.b.d.f.g
    s.a = 20
    s.b.c = 30
    s.b.d.e = 40
    s.b.d.f.g = 50
    assert_equal 20, s.a
    assert_equal 30, s.b.c
    assert_equal 40, s.b.d.e
    assert_equal 50, s.b.d.f.g
    assert_equal 10, d.a
    assert_equal 20, d.b.c
    assert_equal 30, d.b.d.e
    assert_equal 40, d.b.d.f.g
  end

  def test_deep_merge
    s = Settings[
      :a=>10,
      :b=>{
        :c=>20,
        :d=>{
          :e=>30,
          :f=> {
            :g=>40
          }
        }
      }
    ]
    s.merge! :b=>{:cc=>21, :d=>{:ee=>31, :f=>{:g=>400}}}
    assert_equal 10, s.a
    assert_equal 20, s.b.c
    assert_equal 21, s.b.cc
    assert_equal 30, s.b.d.e
    assert_equal 31, s.b.d.ee
    assert_equal 400, s.b.d.f.g
  end

  def test_deep_merge_and_copy
    s = Settings[
      :a=>10,
      :b=>{
        :c=>20,
        :d=>{
          :e=>30,
          :f=> {
            :g=>40
          }
        }
      }
    ]
    d = s.merge :b=>{:cc=>21, :d=>{:ee=>31, :f=>{:g=>400}}}
    assert_equal 10, d.a
    assert_equal 20, d.b.c
    assert_equal 21, d.b.cc
    assert_equal 30, d.b.d.e
    assert_equal 31, d.b.d.ee
    assert_equal 400, d.b.d.f.g
    assert_equal 10, s.a
    assert_equal 20, s.b.c
    assert_equal 30, s.b.d.e
    assert_equal 40, s.b.d.f.g
    assert_nil  s.b.cc
    assert_nil  s.b.d.ee
  end

end
