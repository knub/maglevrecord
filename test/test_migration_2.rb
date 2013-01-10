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
    m = M.with_timestamp('a')
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
    puts "1"
    t1 = Time.gm(2003, 1, 23, 23, 23, 23.23)
    puts "2"
    t2 = Time.new(2003, 1, 23, 23, 17, 23.23, (-60 * 60 * 6))
    puts "3"
    assert_equal t1, t2
    assert t1 <= t2
    assert t1 >= t2
    assert_not t1 > t2
    assert_not t1 < t2
  end
end













