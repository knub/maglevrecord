####
#
#   Test Cases for removing
#
#   - instance variables
#
#   - attributes
#
#   - classes
#

require "maglev_record"
require "migration/operation_setup"
require "more_asserts"
require 'time'

################## remove instance_variable

class TestMigrationRemoveInstanceVariable < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture.fill_with_examples
  end

  def migration1
    MaglevRecord::Migration.new(Time.now, "remove instance variable") do
      def up
        Lecture.delete_instance_variable(:@lecturer)
      end
    end
  end

  def test_instance_variable_is_removed
    migration1.do
    assert_not Lecture.first.instance_variable_defined?(:@lecturer)
    assert_nil Lecture.first.instance_variable_get(:@lecturer)
  end

  def migration2
    MaglevRecord::Migration.new(Time.now, "delete instance variable") do
      def up
        @lecturers = []
        Lecture.delete_instance_variable(:@lecturer) {
          |lecturer|
          # do some garbage collection help
          @lecturers << lecturer
        }
      end
      def lecturers
        @lecturers
      end
    end
  end

  def test_instance_variable_is_removed_with_block
    migration2.do
    assert_not Lecture.first.instance_variable_defined?(:@lecturer)
    assert_nil Lecture.first.instance_variable_get(:@lecturer)
  end

  def test_block_is_called_with_deleted_content
    lecturers = Lectures.collect{ |l| l.instance_variable_get(:@lecturer)}
    migration = migration2
    migration.do
    assert_equal lecturers.sort, migration.lecturers.sort
  end

  def test_first_lecture_has_lecturer
    assert Lecture.first.instance_variable_defined?(:@lecturer)
    assert_not_nil Lecture.first.instance_variable_get(:@lecturer)
  end

end

################## remove attribute

class TestMigrationRemoveAttribute < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture2.fill_with_examples
  end

  def migration1
    MaglevRecord::Migration.new(Time.now, "remove attribute") do
      def up
        Lecture2.delete_attribute(:lecturer)
      end
    end
  end

  def test_instance_variable_is_removed
    migration1.do
    assert_nil Lecture.first.lecturer
  end

  def migration2
    MaglevRecord::Migration.new(Time.now, "remove attribute lecturer") do
      def up
        @lecturers = []
        Lecture.delete_attribute(:lecturer) {
          |lecturer|
          # do some garbage collection help
          @lecturers << lecturer
        }
      end
      def lecturers
        @lecturers
      end
    end
  end

  def test_instance_variable_is_removed_with_block
    migration2.do
    assert_nil Lecture.first.lecturer
  end

  def test_block_is_called_with_deleted_content
    lecturers = Lectures.collect{ |l| l.lecturer }
    migration = migration2
    migration.do
    assert_equal lecturers.sort, migration.lecturers.sort
  end

  def test_first_lecture_has_lecturer
    assert_not_nil Lecture.first.lecturer
  end

end

################## remove attribute

class TestMigrationRemoveAttribute < Test::Unit::TestCase

  def setup
    setup_migration_operations

  end

end

