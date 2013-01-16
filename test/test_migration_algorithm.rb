require "test/unit"
require "maglev_record"

class TestMigrationListBase < Test::Unit::TestCase
  
  class ML < MaglevRecord::MigrationList
  end

  class ML2 < ML
  end

  def setup
    @l = ML.new
  end

  def teardown
    ML.clear
    ML::Migration.clear
  end

  def l
    @l
  end

  def test_nothing
  end

end

class TestMigrationList < TestMigrationListBase

  def test_l_was_created_last
    assert_equal ML.last, l
  end

  def test_clear_clears_all_ML
    ML.clear
    assert_not_equal ML.last, l
  end

  def test_ml_clear_does_not_clear_ml
    l2 = ML2.new
    ML2.clear
    assert_not_equal ML2.last, l2
    assert_equal ML.last, l
  end

  def test_lists_link_to_last_list
    l1 = ML.last
    l2 = ML.new
    l3 = ML.new
    l4 = ML.new
    assert_equal l1, l2.parent
    assert_equal l2, l3.parent
    assert_equal l3, l4.parent
  end

  def test_first_is_last_if_there_is_no_migration
    assert_equal l.last_migration, l.first_migration
  end

  # make sure that we have always one root
  def test_consistent_if_root_is_first
    m = l.migration(1).follows(l.first_migration)
    assert l.consistent?
  end

  def test_not_consistent_if_root_not_first
    m = l.migration(1)
    m = l.migration(2).follows(m)
    m = l.migration(3).follows(m)
    m = l.migration(4).follows(m)
    assert !l.consistent?
  end

end

class TestMigrationList_Scenario < TestMigrationListBase

  def setup_scenario_1
    @m1 = l.migration(1).follows(l.first_migration).up{list << 1}.down{list.delete(1)}
    @m2 = l.migration(2).follows(@m1).up{list << 2}.down{list.delete(2)}
    @m3 = ML::Migration.with_timestamp(3).follows(@m2).up{list << 3}.down{list.delete(3)}
    @m4 = l.migration(4).follows(@m3).up{list << 4}.down{list.delete(4)}

    @l2 = ML.new
    @ma = ML::Migration.with_timestamp(97).follows(@m2).up{list << "a"}.down{list.delete("a")}
    @mb = @l2.migration(98).follows(@ma).up{list << "b"}.down{list.delete("b")}
  end

  def setup
    super
    @list = []
    setup_scenario_1
  end

  def list
    @list
  end

  def l2
    @l2
  end

  def first_m
    l.first_migration
  end

  def test_list_empty
    assert_equal list, []
  end

  def test_1_up
    l.up
    assert_equal list, [1,2,3,4]
  end

  def test_2_up
    l2.up
    assert_equal list, [1,2,"a","b"]
  end

  def test_up_1_2
    l.up
    l2.up
    assert_equal list, [1,2,"a","b"]
  end

  def test_up_twice
    l.up
    l.up
    assert_equal list, [1,2,3,4]
  end

  def test_error_if_migration_up_in_between
    @m2.do
    assert !l.consistent?
    assert_raise(ML::InconsistentMigrationState) {
      l.up
    }
    assert !l2.consistent?
    assert_equal list, [2]
    assert_raise(ML::InconsistentMigrationState) {
      l2.up
    }
    assert_equal list, [2]
  end

  def test_get_list_of_migrations
    assert_equal l.migrations, [first_m, @m1, @m2, @m3, @m4]
    assert_equal l2.migrations, [first_m, @m1, @m2, @ma, @mb]
  end

  def test_migrations_to_do
    assert_equal l.migrations_to_do, [first_m, @m1, @m2, @m3, @m4]
    assert_equal l2.migrations_to_do, [first_m, @m1, @m2, @ma, @mb]
    l.up
    assert_equal l2.migrations_to_do, [@ma, @mb]
  end

  def test_migrations_done
    assert_equal l.migrations_done, []
    assert_equal l2.migrations_done, []
    l.up
    assert_equal l.migrations_done, l.migrations
    assert_equal l2.migrations_done, [first_m, @m1, @m2]
  end

  def test_migrations_to_undo
    assert_equal l.migrations_to_undo, []
    assert_equal l2.migrations_to_undo, []
    l.up
    assert_equal l2.migrations_to_undo, [@m3, @m4]
  end


end
