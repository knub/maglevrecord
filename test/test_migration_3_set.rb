require "test/unit"
require "maglev_record"

class TestMigrationSetBase < Test::Unit::TestCase
  
  class S < MaglevRecord::MigrationSet
  end

  class M < MaglevRecord::Migration
  end

  def setup
    @s = S.new
  end

  def teardown
    M.clear
  end

  def s
    @s
  end

  def test_nothing
  end

  def m(timestamp, *parent_timestamps)
    migration = M.with_timestamp(timestamp)
    parent_timestamps.each{ |parent_timestamp| 
      migration.follows(m(parent_timestamp))
    }
    s.add(migration)
    migration
  end

  def ms(*timestamps)
    timestamps.map{ |timestamp| m(timestamp)}
  end


end


class TestMigrationList_migration_sequence  < TestMigrationSetBase

  alias :mf :m

  def assert_migration_sequence(*names)
    list = ms(*names)
    assert_equal s.migration_sequence, list
  end

  def setup
    super
    m(1).follows(M.first)
  end

  def test_order_ms_no_parent
    mf(1)
    mf(3)
    mf(2)
    assert_migration_sequence(1,2,3)
    assert !s.has_circle?
    assert_equal s.circles, Set.new([])
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
    assert_equal s.circles, Set.new([ms(1,2,3,4,5)])
    assert s.has_circle?
#    assert !s.consistent? # todo!
    assert_raises(S::CircularMigrationOrderError){
      s.migration_sequence
    }
  end

  def test_split
    mf(2, 1)
    mf(3, 1)
    mf(4, 3)
    mf(5, 2)
    assert_migration_sequence(1,2,3,4,5)
  end

  def test_merge
    mf(1)
    mf(2)
    mf(3, 1, 2)
    mf(4, 3)
    assert_migration_sequence(1,2,3,4)
  end

  def test_several_merges
    mf(3, 1); mf(2, 1)
    mf(5, 3); mf(4, 3, 2)
    mf(7, 5); mf(6, 4)
    mf(9, 7); mf(8, 6, 9)
    assert_migration_sequence(1, 2, 3, 4, 5, 6, 7, 9, 8)
  end

  def test_get_heads
    mf(2, 1)
    mf(31, 2)
    mf(32, 2)
    mf(33, 3)
    mf(35, 33)
    mf(3, 2)
    mf(34, 33, 32)
    mf(55, 31, 3)
    assert_equal s.heads, Set.new(ms(34, 35, 55))
  end

  def test_get_head
    mf(2,1)
    assert_equal s.heads, Set.new(ms(2))
  end

  def test_get_clusters
    mf(2, 1)
    mf(3, 4)
    mf(5, 2)
    mf(22,33)
    mf(6, -23)
    x = ms(1, 2, 5)
    assert_equal(s.clusters, Set.new([x, ms(3,4), ms(22,33), ms(-23, 6)]))
  end

  def test_no_clusters
    s = S.new
    assert_equal s.clusters, Set.new
  end

  def test_expand
    assert !s.include?(M.first)
    assert_equal s.expand!, s
    assert s.include(M.first)
  end

  def test_copy
    s2 = s.copy
    m = M.with_timestamp(3)
    s2.add m
    assert s2.include? m
    assert ! s.include?(m)
  end

  def test_expand
    s2 = s.expanded
    assert s2.include? M.first
    assert ! s.include?(M.first)
  end

end

class TestMigrationSet < TestMigrationSetBase

  def test_sort_by_time
    m(2)
    m(1)
    m(1)
    m(3)
    m(4)
    assert_equal s.migrations_by_time, ms(1,2,3,4)
  end

  def test_create_with_migrations
    m(3,1)
    a1 = S.new([m(1, 5), m(4)])
    assert a1.include?(m(1))
    assert ! a1.include?(m(2))
    assert a1.include?(m(4))
    assert ! a1.include?(m(5))
    assert ! a1.include?(m(3))
    a1.expand!
    assert a1.include?(m(5))
    assert a1.include?(m(3))
  end

  def test_no_circle
    m(1,2)
    m(2,3)
    assert_equal s.circles, Set.new
    assert !s.has_circle?
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
    assert s.has_circle?
    assert_equal s.circles, Set.new([ms(1,2), ms(4,5,6)])
  end

  def test_clusters
    m(3, 1)
    m(2, 1)
    m(4, 6)
    m(7)
    m(10, 11, 12, 13, 14, 15, 16, 17)
    assert_equal s.clusters, Set.new([ms(1,2,3), ms(4, 6), ms(7), ms(10, 11, 12, 13, 14, 15, 16, 17)])
  end

  def test_assert_no_clusters
    assert_equal s.clusters, Set.new
  end

  def test_migration_sequence_not_time
    #
    # it is important that migrations are executed in the order fo time
    #
    m(1, 2, 3) # 1___2___4_
    m(2, 4)    #   \_3_____\5
    m(3, 5)    #
    m(4, 5)    #
    assert !s.has_circle?
    assert_equal s.migration_sequence, ms(5, 3, 4, 2, 1)
  end

  def test_migration_sequence_time
    m(1)
    m(2,1)
    m(3, 2)
    m(4, 2)
    m(5, 3, 4)
    m(6, 5)
    m(7, 5)

    assert_equal s.migration_sequence, ms(1,2,3,4,5,6,7)
  end

  def test_get_migrations
    m(1,2,3)
    assert_equal s.migrations_by_time, ms(1,2,3)
    assert_equal s.migrations, Set.new(ms(1,2,3))
  end

  def test_empty
    assert s.empty?
    m(2)
    assert !s.empty?
  end

  def test_select
    m(1,2,3,4)
    assert_equal s.select{ |m| m.timestamp > 2 }, ms(3, 4)
  end

  def test_tails_parent_not_in_set
    m(1).follows(M.first)
    assert_equal s.tails, Set.new([m(1)])
    s.add(M.first)
    assert_equal s.tails, Set.new([M.first])
  end

  def test_heads_parent_not_in_set
    m(1).follows(M.first)
    m(2, 1)
    m3 = M.with_timestamp(3).follows(m(2))
    assert_equal s.heads, Set.new([m(2)])
    s.add(M.first)
    s.add(m3)
    assert_equal s.heads, Set.new([m3])
  end

end
