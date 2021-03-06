require "maglev_record"
require "more_asserts"
require 'time'

class TestMigration < Test::Unit::TestCase
  Migration = MaglevRecord::Migration

  def setup
    @t1 = "2013-01-20 12:01:03"
    @m = Migration.new(@t1, "migration")
  end

  def test_migration_with_same_timestamp_and_name_is_same_migration
    m1 = Migration.new(@t1, "same")
    m2 = Migration.new(@t1, "same")
    assert_equal m1.id, m2.id
    assert_equal m1, m2
  end

  def test_id_is_not_object_id
    m = Migration.new(@t1, "migration")
    assert_not_equal m.id, m.object_id
  end

  def test_migrations_sort_by_timestamp
    parsed_time = Time.parse(@t1)
    m1 = Migration.new(parsed_time + 1, "migration")
    m2 = Migration.new(parsed_time + 2, "migration")
    m3 = Migration.new(parsed_time + 3, "migration")
    m4 = Migration.new(parsed_time + 4, "migration")
    m5 = Migration.new(parsed_time + 5, "migration")
    l = [m2, m4, m1, m3, m5].sort
    assert_equal l, [m1, m2, m3, m4, m5]
  end

  def test_migrations_sort_by_name_if_timestamp_equal
    parsed_time = Time.parse(@t1)
    m1 = Migration.new(parsed_time + 1, "migration")
    m2 = Migration.new(parsed_time + 1, "zzmigration")
    m3 = Migration.new(parsed_time + 3, "aamigration")
    m4 = Migration.new(parsed_time + 3, "migration")
    m5 = Migration.new(parsed_time + 5, "migration")
    l = [m2, m4, m1, m3, m5].sort
    assert_equal l, [m1, m2, m3, m4, m5]
  end

  def test_id
    assert_equal "20130120120103migration", @m.id
  end

  def test_to_s
    assert_equal Migration.name + "<\"2013-01-20 12:01:03\", \"migration\">", @m.to_s
  end
end


class TestMigrationUpDown < Test::Unit::TestCase
  Migration = MaglevRecord::Migration
  attr_reader :m

  def self.test_list
    @@test_list
  end

  def setup
    @@test_list = []
    @t1 = "2013-01-20 12:01:03"
    @m = Migration.new(@t1, 'test') do
      def up
        TestMigrationUpDown.test_list << 1
      end
      def down
        raise "Wrong call to down" unless TestMigrationUpDown.test_list.delete(1) == 1
      end
    end
  end

  def test_can_be_done
    m.do
    assert m.done?
  end

  def test_new_app_is_not_done
    assert_not m.done?
  end

  def test_undo_fail
    m.undo
  end

  def test_undo_possible
    m.do
    m.undo
    assert_not m.done?
  end

  def test_do
    m.do
    assert_equal @@test_list, [1]
    m.undo
    assert_equal @@test_list, []
  end

  def test_do_twice
    # running do twice only executes it once
    m.do
    m.do
    assert_equal @@test_list.size, 1
  end

  def test_undo_twice
    # assert_equal in down should not throw an error
    m.undo
    m.undo
  end

  def test_can_do_if_up_not_set
    m1 = Migration.new(@t1, 'migration')
    m1.do # raises no error!, but nothing happens :)
    assert_equal @@test_list.size, 0
  end

  def test_can_undo_if_down_not_set
    m1 = Migration.new(@t1, 'migration')
    m1.undo # raises no error!, but nothing happens :)
  end
end