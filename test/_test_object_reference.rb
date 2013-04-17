require "maglev_record"

# use
# bundle exec rake test TESTOPTS="-v" TEST=test/_test_object_reference.rb


module Mod

end

class AA
  include Mod
  attr_accessor :x
end
class BB < AA
end
class CC < BB
end
class DD < CC
end
class EE < DD
end
class OO
end
class X
end

o = OO.new
d = {a:'2', b: 34}
aa = AA.new
aa.x = o;
bb = AA.new
bb.x = aa
cc = AA.new
cc.x = bb
a = b = []
20.times{ a = [a] }
x = class << X
  self
end

def self.assert_equal(v1, v2)
  raise "expected \n#{v1.inspect}\n == \n#{v2.inspect}" unless v1 == v2
end

puts 'test_hash'
assert_equal d.string_reference_path_to(d[:a], 3), "\"2\" is \n      value of :a => \"2\" is \nassociation in {:a=>\"2\", :b=>34}"

puts 'test_superclass'
assert_equal EE.string_reference_path_to(AA, 5), "AA is \nsuperclass of BB is \nsuperclass of CC is \nsuperclass of DD is \nsuperclass of EE"

puts 'test_instance_variable'
assert_equal aa.string_reference_path_to(o, 3), "#{o.inspect} is \n@x in #{aa.inspect}"

puts 'test_class_to_inst_var'
assert_equal cc.string_reference_path_to(OO, 5), "OO is \nclass of #{o.inspect} is \n   @x in #{aa.inspect} is \n   @x in #{bb.inspect} is \n   @x in #{cc.inspect}"

puts 'test_array'
assert_equal a.string_reference_path_to(b, 20), "[] is \nat 0 of [[]] is \nat 0 of [[[]]] is \nat 0 of [[[[]]]] is \nat 0 of [[[[[]]]]] is \nat 0 of [[[[[[]]]]]] is \nat 0 of [[[[[[[]]]]]]] is \nat 0 of [[[[[[[[]]]]]]]] is \nat 0 of [[[[[[[[[]]]]]]]]] is \nat 0 of [[[[[[[[[[]]]]]]]]]] is \nat 0 of [[[[[[[[[[[]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[]]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[[]]]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]] is \nat 0 of [[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]"

puts 'test_eigenclass'
assert_equal X.string_reference_path_to(x, 5), "#{x.inspect} is \neigenclass of X"

puts 'test_eigenclass_base'
assert_equal x.string_reference_path_to(X, 5), "X is \neigenbase of #{x.inspect}"

puts 'test_include'
assert_equal AA.string_reference_path_to(Mod, 5), "Mod is \nincluded by AA"

puts 'done!'
