

class TestMigration < MaglevRecord::Migration
end

class TestBook
  def author
    @author
  end
  def author=(author)
    @author = author
  end
end

class TestMigration_list < Test::Unit::TestCase

  alias assert_equals assert_equal

  def M
    TestMigration
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

  def test_first_has_no_predecessor_migration
    assert_equal @first.predecessor, nil
  end

  def test_first_preceeds_new_migration
    m = M.withTimestamp('test').follows(@first)
    assert_equal m.predecessor, M.first
  end

  def test_new_migration_succeeds_first
    m = M.withTimestamp('test').follows(@first)
    assert @first.successors.include? m
  end

  def test_all_migrations_depending_on_an_other_migration_are_its_successors
    m = M.withTimestamp('a')
    x = 10
    ms = (1..x).each { |n|
      m.withTimestamp(n).follows(m)
    }
    ms.each{ |m2| 
      assert_equal m2.predecessor, m
      assert m.successors.include? m2
    }
  end

  def test_new_migration_has_no_successors
    m = M.withTimestamp('tritra')
    assert_equal m.successors.size, 0
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
    assert_equal m.predecessor, f
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















