require "test_migration_loader_base"

class TestMigrationAlgorithm < Test::Unit::TestCase

  Migration = MaglevRecord::Migration
  def setup
    # Remember for all tests:
    # This set contains the desired state for all migrations.
    # All migrations in this set should be applied,
    # all migrations not in this set should not be applied.
    Migration.clear
    @migrations = MigrationSet.new
  end

  def alg
    MigrationAlgorithm.new(@migrations)
  end

  ###
  ## Factory methods for creating test setups
  ###

  # Creates a migration graph with the first argument being the head,
  # and the following being its parents.
  # m_with_parents(1, 2, 3, 4) =
  #  1
  # | \ \
  # 2 3 4
  def m_with_parents(timestamp, *parent_timestamps)
    m = Migration.with_timestamp(timestamp)
    parent_timestamps.each { |parent_timestamp|
      m.follows(Migration.with_timestamp(parent_timestamp))
    }
    m
  end

  # Same as m_with_parents, but also adds to the MigrationSet instance
  # which will be passed to the algorithm when calling alg.
  def m_with_parents_in_set(timestamp, *args)
    m = m_with_parents(timestamp, *args)
    @migrations.add(m)
    m
  end

  # Just some assert helper to test undo, skip and todo.
  def assert_lists(undo, skip, todo)
    li = []
    li << alg.migrations_to_undo.map{|m|m.timestamp}
    li << alg.migrations_to_skip.map{|m|m.timestamp}
    li << alg.migrations_to_do.map{|m|m.timestamp}
    assert_equal li, [undo, skip, todo]
  end

  def test_has_nothing
    # 2 → 3
    m_with_parents(2, 3)
    assert_lists([], [2,3], [])
  end

  def test_undo
    # 4 → 2 → 3
    #      5 ↗
    m_with_parents(2, 3).do
    m_with_parents(4, 2)
    m_with_parents(5, 3)
    # set is empty, so 2 needs to be undone
    assert_lists([2], [3, 4, 5], [])
  end

  def test_do
    # 4 → 2 → 3
    #      5 ↗
    m2 = m_with_parents_in_set(2, 3)
    m4 = m_with_parents(4, 2)
    m_with_parents(5, 3)
    assert_include? m4.parents, m2
    assert_lists([], [4, 5], [3, 2])
  end

  def test_skip
    m_with_parents_in_set(2).do
    # 2 is already done, so should be in skip list now
    assert_lists([], [2], [])
  end

  def test_skip_todo_undo
    # 2 → 3, 4
    m_with_parents_in_set(2,3)
    m_with_parents(4).do
    m_with_parents_in_set(3).do
    # 2 is in set, and not done, so needs to be done
    # 3 is in set and done, so everything is fine
    # 4 is done, but not in set, so needs to be undone
    assert_lists([4], [3], [2])
  end

  def test_big_scenario
    # 4 → 2.5
    # 8 →             4 → 2done → 1done
    # 8 → 6.5 → 6 → 4
    # 7 → 5done → 3done → 1done
    #
    # in set for algorithm: 8, 6.5, 6, 1, 2
    m_with_parents_in_set(1).do
    m_with_parents_in_set(2, 1).do
      m_with_parents(3, 1).do # detached branch
      m_with_parents(5, 3).do
      m_with_parents(7, 5)
    m_with_parents(4, 2)
    m_with_parents(4, 2.5)
        m_with_parents(2.5)
    m_with_parents_in_set(8, 4, 6.5)
    m_with_parents_in_set(6.5, 6)
    m_with_parents_in_set(6, 4)
    # 1 is in set and done, so everything is fine
    # 2 is in set and done, so everything is fine
    # 3 is not in set but done, so needs to be undone
    # 4 is not in set, but 8 is, which depends on 4, so 4 needs to be done
    # 4 depends on 2.5, so 2.5 needs to be done as well
    # 5 is done, but not in set, so needs to be undone
    # 6 is in set and not done, so needs to be done
    # 6.5 is in set but not done, so needs to be done
    # 7 is not in set and undone, so can be skipped
    # 8 is in set but not done, so needs to be done
    assert_lists([5, 3], [1, 2, 7], [2.5, 4, 6, 6.5, 8])
  end

end



class TestMigrationList_Scenario < TestMigrationLoaderBase

  def setup_first_migrations
    @m1 = Migration.with_timestamp(1).follows(Migration.first).up{list << 1}.down{list.delete(1)}
    @m2 = Migration.with_timestamp(2).follows(@m1).up{list << 2}.down{list.delete(2)}
  end

  def setup_list_1
    @l1_setup = true
    @l = Migration.new
    @m3 = Migration.with_timestamp(3).follows(@m2).up{list << 3}.down{list.delete(3)}
    @m4 = l.migration(4).follows(@m3).up{list << 4}.down{list.delete(4)}
  end

  def setup_list_2
    @l2_setup = true
    @l2 = Migration.new
    @ma = Migration.with_timestamp(97).follows(@m2).up{list << "a"}.down{list.delete("a")}
    @mb = @l2.migration(98).follows(@ma).up{list << "b"}.down{list.delete("b")}
  end

  def setup_list_3
    @l3_setup = true
    @l3 = Migration.new
    @mA = Migration.with_timestamp("A").follows(l3.first_migration).up{list << "A"}.down{list.delete("A")}
    @mC = Migration.with_timestamp("C").follows(@mA).up{list << "C"}.down{list.delete("C")}
    @mB = l3.migration("B").follows(@mC).up{list << "B"}.down{list.delete("B")}
  end

  def setup
    @list = []
    setup_first_migrations
  end

  def list
    @list
  end

  def l
    setup_list_1 if not @l1_setup
    @l
  end

  def l2
    setup_list_2 if not @l2_setup
    @l2
  end

  def l3
    setup_list_3 if not @l3_setup
    @l3
  end

  def first_m
    l.first_migration
  end

  def test_list_empty
    assert_equal list, []
  end

  def test_1_up
    l2
    l.up
    assert_equal list, [1,2,3,4]
  end

  def test_2_up
    l2.up
    assert_equal list, [1,2,"a","b"]
  end

  def test_up_1_2
    l2
    l.up
    assert_equal l2.migrations_to_do, [@ma, @mb]
    assert_equal l2.migrations_to_undo, [@m4, @m3]
    l2.up
    assert_equal list, [1,2,"a","b"]
  end

  def test_up_2_1
    l2.up
    l.up
    assert_equal list, [1,2,3,4]
  end

  def test_up_twice
    l.up
    l.up
    assert_equal list, [1,2,3,4]
  end

  def test_error_if_migration_up_in_between
    @m2.do
    assert !l.consistent?
    assert_raise(InconsistentMigrationState) {
      l.up
    }
    assert !l2.consistent?
    assert_equal list, [2]
    assert_raise(InconsistentMigrationState) {
      l2.up
    }
    assert_equal list, [2]
  end

  def test_get_list_of_migrations
    assert_equal l.migrations, [first_m, @m1, @m2, @m3, @m4]
    assert_equal l2.migrations, [first_m, @m1, @m2, @m3, @m4, @ma, @mb]
  end

  def test_migrations_to_do
    assert_equal l.migrations_to_do, [first_m, @m1, @m2, @m3, @m4]
    assert_equal l2.migrations_to_do, [first_m, @m1, @m2, @ma, @mb]
    l.up
    assert_equal l2.migrations_to_do, [@ma, @mb]
  end

  def test_migrations_to_skip
    l
    l2
    assert_equal l.migrations_to_skip, [@ma, @mb]
    assert_equal l2.migrations_to_skip, [@m3, @m4]
    l.up
    assert_equal l.migrations_to_skip, l.migrations
    assert_equal l.migrations_to_do, []
    assert_equal l.migrations_to_undo, []
    assert_equal l2.migrations_to_skip, [first_m, @m1, @m2]
    assert_equal l2.migrations_to_do, [@ma, @mb]
    assert_equal l2.migrations_to_undo, [@m4, @m3]
  end

  def test_migrations_to_undo
    assert_equal l.migrations_to_undo, []
    assert_equal l2.migrations_to_undo, []
    l.up
    assert_equal l2.migrations_to_undo, [@m4, @m3]
  end

  def test_migrations_are_executed_in_follower_order
    l3.up
    assert_equal list, ["A", "C", "B"]
  end

  def test_migrations_to_do
    l
    l2
    assert_equal l.migrations_to_do, [first_m, @m1, @m2, @m3, @m4]
    assert_equal l2.migrations_to_do, [first_m, @m1, @m2, @ma, @mb]
    l2.up
    assert_equal l.migrations_to_do, [@m3, @m4]
    assert_equal l2.migrations_to_do, []
    l.up
    assert_equal l.migrations_to_do, []
    assert_equal l2.migrations_to_do, [@ma, @mb]

  end

end


