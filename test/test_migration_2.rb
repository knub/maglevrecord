require "test/unit"
require "maglev_record"


class TestBook
  def author
    @author
  end
  def author=(author)
    @author = author
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
    m1 = M.withTimestamp('hallo')
    m2 = M.withTimestamp('hallo')
    assert_equal m1, m2
  end

  def test_first_has_no_parent_migration
    assert_equal @first.parent, nil
  end

  def test_first_preceeds_new_migration
    m = M.withTimestamp('test').follows(@first)
    assert_equal m.parent, M.first
  end

  def test_new_migration_succeeds_first
    m = M.withTimestamp('test').follows(@first)
    assert @first.children.include? m
  end

  def test_all_migrations_depending_on_an_other_migration_are_its_children
    m = M.withTimestamp('a')
    x = 10
    ms = (1..x).each { |n|
      m.withTimestamp(n).follows(m)
    }
    ms.each{ |m2| 
      assert_equal m2.parent, m
      assert m.children.include? m2
    }
  end

  def test_new_migration_has_no_children
    m = M.withTimestamp('tritra')
    assert_equal m.children.size, 0
  end

  def test_M_clear
    m = M.withTimestamp('test')
    M.clear
    assert_equal M.size, 0
  end

  def test_M_size
    old_size = M.size
    M.withTimestamp('lilalu')
    assert_equal old_size + 1, M.size
  end

  def test_follow_same_migration_twice
    f = M.withTimestamp('axyz')
    m = M.withTimestamp('casd').follow(f)
    m.follow(f)
    assert_equal m.parent, f
  end

  def test_follow_different_migrations
    # TODO: do something better than error
    f = M.withTimestamp('axyz')
    m = M.withTimestamp('casd').follow(f)
    assert_raise(ArgumentError) {
      m.follow(M.first)
    }
  end

  def test_can_follow_with_higher_timestamp
    m1 = M.withTimestamp('aaa').follow(@first)
    m2 = M.withTimestamp('aab').follow(m1)
    m3 = M.withTimestamp('aad').follow(m2)
    assert_raise(ArgumentError) {
      m4 = M.withTimestamp('aac').follow(m3)
    }
  end

  def test_can_not_follow_myself
    m = M.withTimestamp("2")
    assert_raise(ArgumentError){
      m.follow(m)
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
    t1 = Time.gm(2003, 1, 23, 23, 23, 23.23)
    t2 = Time.new(2003, 1, 23, 23, 17, 23.23, -60 * 60 * 6)
    assert_equal t1, t2
    assert t1 <= t2
    assert t1 >= t2
    assert_not t1 > t2
    assert_not t1 < t2
  end
end













