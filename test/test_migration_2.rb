require "test/unit"
require "maglev_record"

require 'time'

class TestBook
  def author
    @author
  end
  def author=(author)
    @author = author
  end
end

class Test::Unit::TestCase
  def assert_not(bool, message = nil)
    assert_equal false, bool, message
  end
end
 

#
# only for parent and successor
#
class TestMigration_list < Test::Unit::TestCase

  alias assert_equals assert_equal

  class M < MaglevRecord::Migration
  end

  class M2 < M
  end

  def setup
    @first = M.first
  end

  def teardown
    M.clear
  end

  def test_clear_on_subclass_does_not_clear_class
    m1 = M.with_timestamp('test1')
    m2 = M2.with_timestamp('test2')
    M2.clear
    assert m1.equal? M.with_timestamp('test1')
    assert_not m2.equal? M2.with_timestamp('test2')
  end

  def test_get_timestamp
    o = Object.new
    m1 = M.with_timestamp(o)
    assert_equal m1.timestamp, o
  end

  def test_first_is_always_first
    assert_equal(M.first, @first)
  end

  def test_migration_with_same_timestamp_is_same_migration
    m1 = M.with_timestamp('hallo')
    m2 = M.with_timestamp('hallo')
    assert_equal m1, m2
  end

  def test_first_has_no_parent_migration
    assert_equal @first.parents, []
  end

  def test_first_preceeds_new_migration
    m = M.with_timestamp('test').follows(@first)
    assert_equal m.parents, [M.first]
  end

  def test_new_migration_succeeds_first
    m = M.with_timestamp('test').follows(@first)
    assert @first.children.include? m
  end

  def test_all_migrations_depending_on_an_other_migration_are_its_children
    m = M.with_timestamp(0)
    x = 10
    ms = (1..x).collect { |n|
      M.with_timestamp(n).follows(m)
    }
    ms.each{ |m2| 
      assert_equal m2.parents, [m]
      assert m.children.include? m2
    }
  end

  def test_new_migration_has_no_children
    m = M.with_timestamp('tritra')
    assert_equal m.children.size, 0
  end

  def test_M_clear
    m = M.with_timestamp('test')
    M.clear
    assert_equal M.size, 0
  end

  def test_clear2
    m = M.with_timestamp('test_clear')
    M.clear
    assert_not m.equal? M.with_timestamp('test_clear')
  end

  def test_M_size
    old_size = M.size
    M.with_timestamp('lilalu')
    assert_equal old_size + 1, M.size
  end

  def test_follow_same_migration_twice
    f = M.with_timestamp('axyz')
    m = M.with_timestamp('casd').follows(f)
    m.follows(f)
    assert_equal m.parents, [f]
  end

  def test_follow_different_migrations
    f = M.with_timestamp('axyz')
    m = M.with_timestamp('casd').follows(f)
    m.follows(M.first)
    assert_equal m.parents, [f, M.first]
  end

  def test_can_follow_with_higher_timestamp
    m1 = M.with_timestamp('aaa').follows(@first)
    m2 = M.with_timestamp('aab').follows(m1)
    m3 = M.with_timestamp('aad').follows(m2)
    m4 = M.with_timestamp('aac').follows(m3)
    assert_equal m4.parents, [m3]
    assert_equal m3.children, [m4]
  end

  def test_can_not_follow_myself
    m = M.with_timestamp("2")
    assert_raise(ArgumentError){
      m.follows(m)
    }
  end

  def test_migration_is_not_nil
    assert_not M.first.nil?
    assert_not M.with_timestamp('lala').nil?
  end

  def test_a_migration_with_two_children
    m1 = M.with_timestamp(1)
    m2 = M.with_timestamp(2).follows(m1)
    m3 = M.with_timestamp(3).follows(m1)
    m3 = M.with_timestamp(3).follows(m1)
    assert_equal m1.children, [m2, m3]
  end

  def test_add_child
    m1 = M.with_timestamp('a')
    m2 = M.with_timestamp('b')
    m3 = M.with_timestamp('c').add_child(m1).add_child(m2).add_child(m2)
    assert_equal m3.children, [m1, m2]
    assert_equal m1.parents, [m3]
    assert_equal m2.parents, [m3]
  end

  def test_add_self_as_child
     m1 = M.with_timestamp('a')
     assert_raise(ArgumentError){
       m1.add_child(m1)
     }
  end

end

class TestMigration_Timestamp < Test::Unit::TestCase
  
  class M < MaglevRecord::Migration
  end

  def test_migration_now_returns_time
    t1 = Time.now
    t2 = M.now
    t3 = Time.now
    assert t1 <= t2
    assert t2 <= t3
  end

  def test_can_use_time_as_Migration_timestamp 
    # time_compares_independent_from_zone
    #
    # check if we can use timestamps as migration ids
    # therefore we need a order (>, <, <=, >=, ==)
    #
    t1_str = "2003-01-23 23:23:23 +01:00"
    t2_str = "2003-01-23 17:23:23 -05:00"

    t1 = Time.parse(t1_str)
    t2 = Time.parse(t2_str)
    assert_equal t1, t2
    assert t1 <= t2
    assert t1 >= t2
    assert_equal false, t1 > t2     # assert_not does not exist
    assert_equal false, t1 < t2
  end
end


class TestMigration_comparism < Test::Unit::TestCase

  class M < MaglevRecord::Migration
  end

  class T < M::FirstTimestamp

  end

  def test_first_is_smaller_than_everything
    f = M.first.timestamp
    assert_first_timestamp(f)
  end

  def test_first_timestamp_is_smaller_than_everything
    assert_first_timestamp(T.new)
  end

  def assert_first_timestamp(f)
    assert f == f,  "=="
    assert_not f < f, "<"
    assert_not f > f, ">"

    assert f < 1, "< 1"
    assert_not f > 1, "> 1"
    assert_not f == 1, "== 1"
    assert f < "smile", "< x"
    assert_not f > "smile", "> x"
    assert_not f == "smile", "== x"
    assert f <= "trila", "<= x"
    assert_not f >= "trila", ">= x"

#    assert 1 > f, "< 1"
#    assert_not 1 < f, "> 1"
#    assert_not 1 == f, "== 1"
#    assert "smile" > f, "< x"
#    assert_not "smile" < f, "> x"
#    assert_not "smile" == f, "== x"
#    assert "trila" >= f, "<= x"
#    assert_not "trila" <= f, ">= x"
  end

  def test_first_timestamp_hashes_equal
    assert_equal T.new.hash, T.new.hash
  end

  def test_migrations_sort_by_timstamp
    m1 = M.with_timestamp(1)
    m5 = M.with_timestamp(5)
    m4 = M.with_timestamp(4)
    m2 = M.with_timestamp(2)
    m3 = M.with_timestamp(3)
    l = [m2, m4, m1, m3, m5].sort
    assert_equal l, [m1, m2, m3, m4, m5]
  end

end

class TestMigration_up_and_down < Test::Unit::TestCase

  class M < MaglevRecord::Migration
  end

  def setup
    @l = []
    @m = M.with_timestamp('test')
    m.up{
      l << 1
    }
    m.down{
      assert_equal(l.delete(1), 1)
    }
  end

  def m
    @m
  end

  def l
    @l
  end

  def teardown
    M.clear
  end

  def test_can_be_done
    m.do
    assert m.done?
  end

  def test_new_app_is_not_done
    assert_equal m.done?, false
  end

  def test_undo_fail
    assert_raise(M::DownError) {
      m.undo
    }
  end

  def test_undo_possible
    m.do
    m.undo
    assert_equal m.done?, false
  end

  def test_do
    m.do
    assert_equal l, [1]
    m.undo
    assert_equal l, []
    assert_raise(M::DownError){
      m.undo
    }
  end

  def test_do_twice
    m.do
    assert_raise(M::UpError) {
      m.do
    }
  end

  def test_up_twice
    assert_raise (ArgumentError) {
      m.up {}
    }
  end

  def test_down_twice
    assert_raise (ArgumentError) {
      m.down {}
    }
  end

  def test_can_do_if_up_not_set
    m1 = M.with_timestamp('test2')
    m1.do # raises no error!
  end

  def test_can_undo_if_down_not_set
    m1 = M.with_timestamp('test2')
    m1.up {}
    m1.do 
    m1.undo # raises no error!
  end

  def test_can_not_define_up_and_down_on_first
    f = M.first
    assert_raise(ArgumentError) {
      f.up {}
    }
    assert_raise(ArgumentError) {
      f.down {}
    }
  end

  def test_has_no_up_down
    m = M.with_timestamp('abc')
    assert_not m.has_up?
    assert_not m.has_down?
  end

  def test_has_up
    m = M.with_timestamp('abc')
    m.up {}
    assert m.has_up?
  end

  def test_has_down
    m = M.with_timestamp('abc')
    m.down {}
    assert m.has_down?
  end
end

class TestMigration_conversion < Test::Unit::TestCase

  class M < MaglevRecord::Migration
  end

  class M3 < M
  end

  def test_to_s_with_timestamp
    assert_equal M.with_timestamp("aaa").to_s, M.name + '.with_timestamp("aaa")'
    assert_equal M3.with_timestamp(123).to_s, M3.name + '.with_timestamp(123)'
  end

  def test_inspect_with_timestamp
    assert_equal M.with_timestamp("aaa").inspect, M.name + '.with_timestamp("aaa")'
    assert_equal M3.with_timestamp(123).inspect, M3.name + '.with_timestamp(123)'
  end


end








