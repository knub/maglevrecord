require "test/unit"
require "maglev_record"

class TestMigrationLoaderBase < Test::Unit::TestCase
  
  class ML < MaglevRecord::MigrationLoader
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

class TestMigrationLoader < TestMigrationLoaderBase

  def test_clear_clears_all_ML
    ML.clear
    assert_equal ML.size, 0
  end

  def test_ml_clear_does_not_clear_ml
    l1 = ML.new
    l2 = ML2.new
    s = ML.size
    assert_equal ML2.size, 1
    ML2.clear
    assert_equal ML2.size, 0
    assert_equal ML.size, s
  end


  def test_first_is_last_if_there_is_no_migration
    #assert_equal l.last_migration, l.first_migration
    #TODO!
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

  def test_first_migration_is_always_the_same
    assert_equal ML.new.first_migration, ML.new.first_migration
    assert_equal ML.new.first_migration.hash, ML.new.first_migration.hash
  end

end

class TestMigrationLoader_do_done_undo < TestMigrationLoaderBase

  # create migration without list
  def mm(timestamp, *parents)
    m = ML::Migration.with_timestamp(timestamp)
    parents.each{ |parent| 
      m.follows(mm(parent))
    }
    m
  end

  def m(timestamp, *args)
    m = mm(timestamp, *args)
    l.migration(timestamp)
  end

  def ms(*timestamps)
    timestamps.map{ |timestamp| mm(timestamp)}
  end

  def assert_lists(undo, skip, todo)
    li = []
    li << l.migrations_to_undo.map{|m|m.timestamp}
    li << l.migrations_to_skip.map{|m|m.timestamp}
    li << l.migrations_to_do.map{|m|m.timestamp}
    assert_equal li, [undo, skip, todo]
  end

  def test_has_nothing
    mm(2,3)
    assert_lists([], [2,3], [])
  end

  def test_undo
    mm(2, 3).do
    mm(4, 2)
    mm(5, 3)
    assert_lists([2], [3, 4, 5], [])
  end

  def test_do
    m(2,3)
    mm(4, 2)
    mm(5, 3)
    assert mm(4).follows(mm(2))
    assert_lists([], [4, 5], [3, 2])
  end

  def test_skip
    m(2).do
    assert_lists([], [2], [])
  end

  def test_skip_todo_undo
    m(2,3)
    mm(4).do
    m(3).do
    assert_lists([4], [3], [2])
  end

  def test_big_scenario
    m(1).do
    m(2, 1).do
      mm(3, 1).do # detached branch
      mm(5, 3).do
      mm(7, 5)
    mm(4, 2)
    mm(4, 2.5)
        mm(2.5)
    m(8, 4, 6.5)
    m(6.5, 6)
    m(6, 4)
    assert_lists([5, 3], [1, 2, 7], [2.5, 4, 6, 6.5, 8])
  end

end



class TestMigrationList_Scenario < TestMigrationLoaderBase

  def setup_first_migrations
    @m1 = ML::Migration.with_timestamp(1).follows(ML::Migration.first).up{list << 1}.down{list.delete(1)}
    @m2 = ML::Migration.with_timestamp(2).follows(@m1).up{list << 2}.down{list.delete(2)}
  end

  def setup_list_1
    @l1_setup = true
    @l = ML.new
    @m3 = ML::Migration.with_timestamp(3).follows(@m2).up{list << 3}.down{list.delete(3)}
    @m4 = l.migration(4).follows(@m3).up{list << 4}.down{list.delete(4)}
  end

  def setup_list_2
    @l2_setup = true
    @l2 = ML.new
    @ma = ML::Migration.with_timestamp(97).follows(@m2).up{list << "a"}.down{list.delete("a")}
    @mb = @l2.migration(98).follows(@ma).up{list << "b"}.down{list.delete("b")}
  end

  def setup_list_3
    @l3_setup = true
    @l3 = ML.new
    @mA = ML::Migration.with_timestamp("A").follows(l3.first_migration).up{list << "A"}.down{list.delete("A")}
    @mC = ML::Migration.with_timestamp("C").follows(@mA).up{list << "C"}.down{list.delete("C")}
    @mB = ML::Migration.with_timestamp("B").follows(@mC).up{list << "B"}.down{list.delete("B")}
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
    puts "!" * 40
    l2
    l.up
    assert_equal l2.migrations_to_do, [@ma, @mb]
    assert_equal l2.migrations_to_undo, [@m3, @m4]
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
    assert_equal l2.migrations, [first_m, @m1, @m2, @m3, @m4, @ma, @mb]
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

  def test_migrations_are_executed_in_follower_order
    l3.up
    assert_equal l, ["A", "C", "B"]
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



class TestMigrationList_load_migrations # < TestMigrationLoaderBase

  def test_load_simple_migration
    h = l.load_source "
      l = []
      m = migration(1).follows(first_migration)
      m.up{ l << 1 } unless m.has_up?
      m.down{ assert l.delete(1) == 1 } unless m.has_down?
    "
    list = h["l"]
    m = h["m"]
    assert m.is_migration?
    assert ! list.is_migration?
    assert_equal list, []
    assert l.migration_set.include? m
  end

  def test_load_several_migrations
    h1 = l.load_source "
      # TODO: discuss this, could be unliked
      migration(2).follows(first_migration).when_created{ |migration|
        assert migration.timestamp == 2
        l = []
        migration.up{
          l << 2
        }
        migration.down{
          assert l.delete(2) != nil
        }
      }
    "
    s = "
      l = []
      m = migration(3).follows(migration(2))
      m.up{ l << 3
      } unless m.has_up?
      m.down{l << 6} unless m.has_down?
    "
    h2 = l.load_source s
    h3 = l.load_source s
    l.up
    assert_equal h1["l"], [2]
    assert_equal h2["l"], [3]
    assert_equal h3["l"], []
    assert l.migration(2).done?
    l2 = ML.new
    l2.up
    assert_equal h1["l"], []
    assert_equal h2["l"], [3, 6]
    assert_equal h3["l"], []
    assert ! l.migration(2).done?
  end


  
end
