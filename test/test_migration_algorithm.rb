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

  def test_first_of_two_lists_equal
    assert_equal ML2.first, ML2.first
    assert_equal ML2.first.hash, ML2.first.hash
  end

end

class TestMigrationList_Scenario < TestMigrationListBase

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

  def test_up_2_1
    l2.up
    l.up
    assert_equal list, [1,2,3,4]
  end

  def test_parent_of_l
    assert_equal l.parent, ML.first
  end

  def test_parent_of_l2
    assert_equal l2.parent, ML.first
  end

  def test_parent_of_l3
    assert_equal l3.parent, ML.first
  end

  def test_parents_1_2_3
    l
    l2
    l3
    assert_equal l2.parent, l
    assert_equal l3.parent, l2
    assert_equal l.parent, ML.first
  end

  def test_parents_3_1_2
    l3
    l
    l2
    assert_equal l.parent, l3
    assert_equal l2.parent, l
    assert_equal l3.parent, ML.first
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

  def test_migrations_are_executed_in_follower_order
    l3.up
    assert_equal l, ["A", "C", "B"]
  end
end

class TestMigrationList_migration_order # < TestMigrationListBase
  
  def mf(name, *names)
    mig = l.migration(name)
    names.each{ |name|
      mig.follows(l.migration(name))
    }
    mig
  end

  def byName(*names)
    names.collect{ |name| l.migration(name)}
  end

  def setup
    super
    l.migration(1).follows(l.first_migration)
  end

  def test_order_by_name_no_parent
    mf(1)
    mf(3)
    mf(2)
    assert_equal l.migration_order, byName(1,2,3)
  end

  def test_circle
    mf(1,2)
    mf(2,3)
    mf(4,5)
    mf(3,4)
    mf(5,1)
    assert_raises(ML::CircularMigrationOrderError){
      l.migration_order 
    }
  end

  def test_split
    mf(1).follows(l.first_migration)
    mf(2, 1)
    mf(3, 1)
    mf(4, 3)
    mf(5, 2)
    assert_equal l.migration_order, byName(1,2,3,4,5)
  end

  def test_merge
    mf(1)
    mf(2)
    mf(3, 1, 2)
    mf(4, 3)
    assert_equal l.migration_order, byName(1,2,3,4)
  end

  def test_several_merges
    mf(3, 1); mf(2, 1)
    mf(5, 3); mf(4, 3, 2)
    mf(7, 5); mf(6, 4)
    mf(9, 7); mf(8, 6, 9)
    assert_equal l.migration_order, byName(1, 2, 3, 4, 5, 6, 7, 9, 8)
  end

  #TODO: add tests for HEADS (parents)
  
  def test_get_heads
    mf(2, 1)
    mf(31, 2)
    mf(32, 2)
    mf(33, 3)
    mf(35, 33)
    mf(3, 2)
    mf(34, 33, 32)
    mf(55, 31, 3)
    assert_equal l.heads, byName(34, 35, 55)
  end

  def test_get_head
    mf(2,1)
    assert_equal l.heads, byName(2)
  end

end


# liste ist nicht up -> was tun?

