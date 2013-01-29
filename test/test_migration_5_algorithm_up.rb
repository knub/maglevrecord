
# This tests different scenarios of applying the algorithm with a given
# set of desired migrations to be applied.
class TestMigrationList_Scenario < Test::Unit::TestCase
  Migration = MaglevRecord::Migration

  def setup
    Migration.clear
    @list = []
    @m1 = create_migration(1)
    @m2 = create_migration(2).follows(@m1)
    @m3 = create_migration(3).follows(@m2)
    @m4 = create_migration(4).follows(@m3)
    @m5 = create_migration(5).follows(@m2)
    @m6 = create_migration(6).follows(@m5)
    @m8 = create_migration(8).follows(@m2)
    @m7 = create_migration(7).follows(@m8)
    @m9 = create_migration(9).follows(@m7)
    #      ↙ 8← 7 ← 9
    # 1 ← 2 ← 3 ← 4
    #      ↖ 5 ← 6
    @all_migrations = [@m1, @m2, @m3, @m4, @m5, @m6, @m7, @m8, @m9]
  end

  attr_reader :list

  def create_migration(timestamp)
    m = Migration.with_timestamp(timestamp)
    m.up {
      list << timestamp
    }
    m.down {
      assert_equal list.delete(timestamp), timestamp
    }
  end

  def alg1234
    MigrationAlgorithm.new([@m1, @m2, @m3, @m4])
  end

  def alg1256
    MigrationAlgorithm.new([@m1, @m2, @m5, @m6])
  end

  def alg12879
    MigrationAlgorithm.new([@m1, @m2, @m5, @m6])
  end

  def test_1234
    alg1234.up
    assert_equal list, [1,2,3,4]
  end

  def test_1256
    alg1256.up
    assert_equal list, [1,2,5,6]
  end

  def test_up_1234_followed_by_up_1256
    alg1234.up
    # 1 and 2 are already done, so for alg1256 only @m5 and @m6 remain
    assert_equal alg1256.migrations_to_do, [@m5, @m6]
    assert_equal alg1256.migrations_to_undo, [@m4, @m3]
    alg1256.up
    assert_equal list, [1,2,5,6]
  end

  def test_up_1256_followed_by_up_1234
    alg1256.up
    alg1234.up
    assert_equal list, [1,2,3,4]
  end

  def test_up_twice
    alg1234.up
    alg1234.up
    assert_equal list, [1,2,3,4]
  end

  def test_error_if_migration_up_in_between
    @m2.do
    assert_not alg1234.consistent?
    assert_raise(InconsistentMigrationState) {
      alg1234.up
    }
    assert_not alg1256.consistent?
    # no migration has been done, so still only 2 applied
    assert_equal list, [2]
    assert_raise(InconsistentMigrationState) {
      alg1256.up
    }
    # no migration has been done, so still only 2 applied
    assert_equal list, [2]
  end

  def test_get_list_of_migrations
    assert_equal alg1234.all_migrations, @all_migrations
    assert_equal alg1256.all_migrations, @all_migrations
    assert_equal alg12879.all_migrations, @all_migrations
  end

  def test_migrations_to_do
    assert_equal alg1234.migrations_to_do, [@m1, @m2, @m3, @m4]
    assert_equal alg1256.migrations_to_do, [@m1, @m2, @m5, @m6]
    alg1234.up
    assert_equal alg1256.migrations_to_do, [@m5, @m6]
  end

  def test_migrations_to_skip
    assert_equal alg1234.migrations_to_skip, [@m5, @m6, @m7, @m8, @m9]
    assert_equal alg1256.migrations_to_skip, [@m3, @m4, @m7, @m8, @m9]
    alg1234.up
    assert_equal alg1234.migrations_to_skip, alg1234.all_migrations
    assert_equal alg1234.migrations_to_do, []
    assert_equal alg1234.migrations_to_undo, []
    assert_equal alg1256.migrations_to_skip, [@m1, @m2, @m7, @m8, @m9]
    assert_equal alg1256.migrations_to_do, [@m5, @m6]
    assert_equal alg1256.migrations_to_undo, [@m4, @m3]
  end

  def test_migrations_to_undo
    assert_equal alg1234.migrations_to_undo, []
    assert_equal alg12879.migrations_to_undo, []
    alg1234.up
    assert_equal alg12879.migrations_to_undo, [@m4, @m3]
  end

  def test_migrations_are_executed_in_follower_order
    alg12879.up
    assert_equal list, [1, 2, 8, 7, 9]
  end

  def test_migrations_to_do
    assert_equal alg1234.migrations_to_do, [@m1, @m2, @m3, @m4]
    assert_equal alg1256.migrations_to_do, [@m1, @m2, @m5, @m6]
    alg1256.up
    assert_equal alg1234.migrations_to_do, [@m3, @m4]
    assert_equal alg1256.migrations_to_do, []
    alg1234.up
    assert_equal alg1234.migrations_to_do, []
    assert_equal alg1256.migrations_to_do, [@m5, @m6]
  end
end
