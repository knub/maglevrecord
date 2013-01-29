
require "maglev_record"
require "more_asserts"

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
