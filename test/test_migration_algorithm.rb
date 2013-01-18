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

class TestMigrationList_migration_order  < TestMigrationListBase
  
  def mf(name, *names)
    mig = l.migration(name)
    names.each{ |name|
      mig.follows(l.migration(name))
    }
    mig
  end

  def by_name(*names)
    names.collect{ |name| l.migration(name)}
  end

  def assert_migration_order(*names)
    list = by_name(*names)
    list.insert(0, l.first_migration)
    assert_equal l.migration_order, list
  end

  def setup
    super
    l.migration(1).follows(l.first_migration)
  end

  def test_order_by_name_no_parent
    mf(1)
    mf(3)
    mf(2)
    assert_migration_order(1,2,3)
    assert !l.has_circle?
    assert_equal l.circles, Set.new([])
  end

  def test_no_circle

  end

  def test_circle
    mf(1,2)
    mf(2,3)
    mf(4,5)
    mf(3,4)
    mf(5,1)
    mf(1, 11); mf(111, 1)
    mf(2, 22); mf(222, 2)
    mf(3, 33); mf(333, 3, 4)
    mf(4, 44)
    mf(5, 55); mf(555, 5); mf(666, 555)
    assert_equal l.circles, Set.new([by_name(1,2,3,4,5)])
    assert l.has_circle?
    assert !l.consistent?
    assert_raises(ML::CircularMigrationOrderError){
      l.migration_order
    }
  end

  def test_split
    mf(2, 1)
    mf(3, 1)
    mf(4, 3)
    mf(5, 2)
    assert_migration_order(1,2,3,4,5)
  end

  def test_merge
    mf(1)
    mf(2)
    mf(3, 1, 2)
    mf(4, 3)
    assert_migration_order(1,2,3,4)
  end

  def test_several_merges
    mf(3, 1); mf(2, 1)
    mf(5, 3); mf(4, 3, 2)
    mf(7, 5); mf(6, 4)
    mf(9, 7); mf(8, 6, 9)
    assert_migration_order(1, 2, 3, 4, 5, 6, 7, 9, 8)
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
    assert_equal l.heads, by_name(34, 35, 55)
  end

  def test_get_head
    mf(2,1)
    assert_equal l.heads, by_name(2)
  end

  def test_get_clusters
    mf(2, 1)
    mf(3, 4)
    mf(5, 2)
    mf(22,33)
    mf(6, -23)
    x = by_name(2, 1, 5)
    x << l.first_migration
    x.sort!
    assert_equal(l.clusters, Set.new([x, by_name(3,4), by_name(22,33), by_name(-23, 6)]))
  end

  def test_no_clusters
    l = ML.new
    assert_equal l.clusters, Set.new
  end

end


# liste ist nicht up -> was tun?

class TestMigrationGraph < Test::Unit::TestCase

  class M < MaglevRecord::Migration
  end

  class G < MaglevRecord::MigrationList
  end

  def setup
    @a = G.new
    M.clear
  end

  def a
    @a
  end

  def m(timestamp, *parent_timestamps)
    migration = M.with_timestamp(timestamp)
    parent_timestamps.each{ |parent_timestamp| 
      migration.follows(m(parent_timestamp))
    }
    a.add(migration)
    migration
  end

  def ms(*timestamps)
    timestamps.map{ |timestamp| m(timestamp)}
  end

  def test_sort_by_time
    m(2)
    m(1)
    m(1)
    m(3)
    m(4)
    assert_equal a.migrations, ms(1,2,3,4)
  end

  def test_create_with_migrations
    m(3,1)
    a1 = G.new([m(1, 5), m(4)])
    assert a1.include? m(1)
    assert ! a1.include?(m(2))
    assert a1.include? m(4)
    assert ! a1.include?(m(5))
    assert ! a1.include?(m(3))
  end

  def test_no_circle
    m(1,2)
    m(2,3)
    assert_equal a.circles, Set.new
    assert !a.has_circle?
  end

  def test_2_circles
    m(1,2)
    m(2,1)
    m(0, 1)

    m(3, 4, 5)
    m(4, 5)
    m(5, 6)
    m(6, 4)
    m(7, 8)
    assert a.has_circle?
    assert_equal a.circles, Set.new([ms(0,1,2), ms(4,5,6)])
  end

  def test_clusters
    m(3, 1)
    m(2, 1)
    m(4, 6)
    m(7)
    m(10, 11, 12, 13, 14, 15, 16, 17)
    assert_equal a.clusters, Set.new([ms(1,2,3), ms(4, 6), ms(7), ms(10, 11, 12, 13, 14, 15, 16, 17)])
  end

  def test_assert_no_clusters
    assert_equal a.clusters, Set.new
  end

  def test_migration_order_not_time
    m(1, 2, 3)
    m(2, 4)
    m(3, 5)
    m(4, 5)
    assert !a.has_circle?
    assert_equal a.migration_order, ms(5, 3, 4, 2, 1)
  end

  def test_migration_order_time
    m(1)
    m(2,1)
    m(3, 2)
    m(4, 2)
    m(5, 3, 4)
    m(6, 5)
    m(7, 5)

    assert_equal a.migration_order, ms(1,2,3,4,5,6,7)
  end

  def test_get_set_of_migrations
    m(1,2,3)
    assert_equal a.migrations, Set.new(ms(1,2,3))
  end

  def test_empty
    assert a.empty?
    m(2)
    assert !a.empty?
  end
end

class TestMigrationList_load_migrations < TestMigrationListBase

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
