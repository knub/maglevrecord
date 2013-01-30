require "maglev_record"
require "more_asserts"

require 'time'

#
# only for parent and successor
#
class TestMigration_list < Test::Unit::TestCase

  Migration = MaglevRecord::Migration
  def setup
    Migration.clear
  end

  def test_get_timestamp
    # everything can be a timestamp
    o = Object.new
    m1 = Migration.with_timestamp(o)
    assert_equal m1.timestamp, o
  end

  def test_migration_with_same_timestamp_is_same_migration
    m1 = Migration.with_timestamp('hallo')
    m2 = Migration.with_timestamp('hallo')
    assert_equal m1, m2
  end

  def test_first_has_no_parent_migration
    assert_equal @first.parents, []
  end

  def test_first_preceeds_new_migration
    m = Migration.with_timestamp('test').follows(@first)
    assert_equal Migration.parents, [@first]
  end

  def test_new_migration_succeeds_first
    m = Migration.with_timestamp('test').follows(@first)
    assert @first.children.include? m
  end

  def test_all_migrations_depending_on_another_migration_are_its_children
    m = Migration.with_timestamp(0)
    migration_children = (1..10).collect { |n|
      Migration.with_timestamp(n).follows(m)
    }
    migration_children.each { |migration_child|
      assert_equal migration_child.parents, [m]
      assert Migration.children.include? migration_child
    }
  end

  def test_id_is_not_object_id
    m = Migration.with_timestamp(0)
    assert_equal Migration.id, 0
    assert_not Migration.object_id == 0
  end

  def test_new_migration_has_no_children
    m = Migration.with_timestamp('tritra')
    assert_equal Migration.children.size, 0
  end

  def test_M_clear
    m = Migration.with_timestamp('test')
    Migration.clear
    assert_equal Migration.size, 0
  end

  def test_clear2
    m = Migration.with_timestamp('test_clear')
    Migration.clear
    assert_not Migration.equal? Migration.with_timestamp('test_clear')
  end

  def test_M_size
    old_size = Migration.size
    Migration.with_timestamp('lilalu')
    assert_equal old_size + 1, Migration.size
  end

  def test_follow_same_migration_twice
    f = Migration.with_timestamp('axyz')
    m = Migration.with_timestamp('casd').follows(f)
    Migration.follows(f)
    assert_equal Migration.parents, [f]
  end

  def test_follows?
    m1 = Migration.with_timestamp(1)
    m2 = Migration.with_timestamp(2)
    m2.follows(m1)
    assert m2.follows?(m1)
    assert_not m1.follows?(m2)
  end

  def test_follow_different_migrations
    f = Migration.with_timestamp('axyz')
    m = Migration.with_timestamp('casd').follows(f)
    Migration.follows(Migration.first)
    assert_equal Migration.parents, [f, Migration.first]
  end

  def test_can_follow_with_higher_timestamp
    m1 = Migration.with_timestamp('aaa').follows(@first)
    m2 = Migration.with_timestamp('aab').follows(m1)
    m3 = Migration.with_timestamp('aad').follows(m2)
    m4 = Migration.with_timestamp('aac').follows(m3)
    assert_equal m4.parents, [m3]
    assert_equal m3.children, [m4]
  end

  def test_can_not_follow_myself
    m = Migration.with_timestamp("2")
    assert_raise(ArgumentError){
      Migration.follows(m)
    }
  end

  def test_migration_is_not_nil
    assert_not Migration.first.nil?
    assert_not Migration.with_timestamp('lala').nil?
  end

  def test_a_migration_with_two_children
    m1 = Migration.with_timestamp(1)
    m2 = Migration.with_timestamp(2).follows(m1)
    m3 = Migration.with_timestamp(3).follows(m1)
    m3 = Migration.with_timestamp(3).follows(m1)
    assert_equal m1.children, [m2, m3]
  end

  def test_add_child
    m1 = Migration.with_timestamp('a')
    m2 = Migration.with_timestamp('b')
    m3 = Migration.with_timestamp('c').add_child(m1).add_child(m2).add_child(m2)
    assert_equal m3.children, [m1, m2]
    assert_equal m1.parents, [m3]
    assert_equal m2.parents, [m3]
  end

  def test_add_self_as_child
     m1 = Migration.with_timestamp('a')
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
    t2 = Migration.now
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
    f = Migration.first.timestamp
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
    m1 = Migration.with_timestamp(1)
    m5 = Migration.with_timestamp(5)
    m4 = Migration.with_timestamp(4)
    m2 = Migration.with_timestamp(2)
    m3 = Migration.with_timestamp(3)
    l = [m2, m4, m1, m3, m5].sort
    assert_equal l, [m1, m2, m3, m4, m5]
  end

  def test_smaller
    assert Migration.with_timestamp(2) < Migration.with_timestamp(3)
    assert Migration.with_timestamp(1) < Migration.with_timestamp(3)
    assert_not Migration.with_timestamp(3) < Migration.with_timestamp(3)
    assert_not Migration.with_timestamp(3) < Migration.with_timestamp(2)
  end

  def test_greater
    assert_not Migration.with_timestamp(3) > Migration.with_timestamp(3)
    assert_not Migration.with_timestamp(1) > Migration.with_timestamp(3)
    assert Migration.with_timestamp(4) > Migration.with_timestamp(3)
    assert Migration.with_timestamp(3) > Migration.with_timestamp(2)
  end


end

class TestMigration_up_and_down < Test::Unit::TestCase

  class M < MaglevRecord::Migration
  end

  def setup
    @l = []
    @m = Migration.with_timestamp('test')
    Migration.up{
      l << 1
    }
    Migration.down{
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
    Migration.clear
  end

  def test_can_be_done
    Migration.do
    assert Migration.done?
  end

  def test_new_app_is_not_done
    assert_equal Migration.done?, false
  end

  def test_undo_fail
    assert_raise(M::DownError) {
      Migration.undo
    }
  end

  def test_undo_possible
    Migration.do
    Migration.undo
    assert_equal Migration.done?, false
  end

  def test_do
    Migration.do
    assert_equal l, [1]
    Migration.undo
    assert_equal l, []
    assert_raise(M::DownError){
      Migration.undo
    }
  end

  def test_do_twice
    Migration.do
    assert_raise(M::UpError) {
      Migration.do
    }
  end

  def test_up_twice
    assert_raise (ArgumentError) {
      Migration.up {}
    }
  end

  def test_down_twice
    assert_raise (ArgumentError) {
      Migration.down {}
    }
  end

  def test_can_do_if_up_not_set
    m1 = Migration.with_timestamp('test2')
    m1.do # raises no error!
  end

  def test_can_undo_if_down_not_set
    m1 = Migration.with_timestamp('test2')
    m1.up {}
    m1.do
    m1.undo # raises no error!
  end

  def test_can_not_define_up_and_down_on_first
    f = Migration.first
    assert_raise(ArgumentError) {
      f.up {}
    }
    assert_raise(ArgumentError) {
      f.down {}
    }
  end

  def test_has_no_up_down
    m = Migration.with_timestamp('abc')
    assert_not Migration.has_up?
    assert_not Migration.has_down?
  end

  def test_has_up
    m = Migration.with_timestamp('abc')
    Migration.up {}
    assert Migration.has_up?
  end

  def test_has_down
    m = Migration.with_timestamp('abc')
    Migration.down {}
    assert Migration.has_down?
  end
end

class TestMigration_conversion < Test::Unit::TestCase

  class M < MaglevRecord::Migration
  end

  class M3 < M
  end

  def test_to_s_with_timestamp
    assert_equal Migration.with_timestamp("aaa").to_s, Migration.name + '.with_timestamp("aaa")'
    assert_equal M3.with_timestamp(123).to_s, M3.name + '.with_timestamp(123)'
  end

  def test_inspect_with_timestamp
    assert_equal Migration.with_timestamp("aaa").inspect, "<#{Migration.name} \"aaa\">"
    assert_equal M3.with_timestamp(123).inspect, "<#{M3.name} 123>"
  end

  def test_inspect_with_timestamp_and_up
    m = Migration.with_timestamp('lalilu')
    Migration.do
    assert_equal Migration.inspect, "<#{Migration.name} \"lalilu\" done>"
  end

  def test_first_inspect
    assert_equal Migration.first.inspect, "<#{Migration.name} first>"
  end

  def test_first_to_s
    assert Migration.first.first?
    assert_equal Migration.first.to_s, Migration.name + ".first"
  end

end
