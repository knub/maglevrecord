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

  def setup
    @first = M.first
  end

  def teardown
    M.clear
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
    assert_equal @first.parent, nil
  end

  def test_first_preceeds_new_migration
    m = M.with_timestamp('test').follows(@first)
    assert_equal m.parent, M.first
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
      assert_equal m2.parent, m
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

  def test_M_size
    old_size = M.size
    M.with_timestamp('lilalu')
    assert_equal old_size + 1, M.size
  end

  def test_follow_same_migration_twice
    f = M.with_timestamp('axyz')
    m = M.with_timestamp('casd').follows(f)
    m.follows(f)
    assert_equal m.parent, f
  end

  def test_follow_different_migrations
    # TODO: do something better than error
    f = M.with_timestamp('axyz')
    m = M.with_timestamp('casd').follows(f)
    assert_raise(ArgumentError) {
      m.follows(M.first)
    }
  end

  def test_can_follow_with_higher_timestamp
    m1 = M.with_timestamp('aaa').follows(@first)
    m2 = M.with_timestamp('aab').follows(m1)
    m3 = M.with_timestamp('aad').follows(m2)
    assert_raise(ArgumentError) {
      m4 = M.with_timestamp('aac').follows(m3)
    }
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

class TestMigration_attributes < Test::Unit::TestCase

  class M < MaglevRecord::Migration
  end
  
  def test_get_timestamp
    o = Object.new
    m1 = M.with_timestamp(o)
    assert_equal m1.timestamp, o
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











