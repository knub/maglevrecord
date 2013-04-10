####
#
#   Test Cases for renaming
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


################## rename instance variables

class TestMigrationRenameInstanceVariable < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture.fill_with_examples
  end

  def m1
    MaglevRecord::Migration.new(Time.now, "rename instance variable") do
      def up
        Lecture.rename_instance_variable(:@lecturer , :@lecturers) {
          |lecturer|
          [lecturer]
        }
      end
    end
  end

  def test_rename_inst_var_with_block
    lecturer = Lecture.first.instance_variable_get(:@lecturer)
    m1.do
    assert_equal Lecture.first.instance_variable_get(:@lecturers), [lecturer]
  end

  def test_lecturer_exists
    assert_not_nil Lecture.first.instance_variable_get(:@lecturer)
  end

  def m2
    MaglevRecord::Migration.new(Time.now, "rename instance variable") do
      def up
        Lecture.rename_instance_variable(:@users , :@attendees)
      end
    end
  end

  def test_rename_inst_var
    users = Lecture.first.instance_variable_get(:@users)
    m2.do
    assert_equal Lecture.first.instance_variable_get(:@attendees), users
  end

  def test_users_exists
    assert_not_nil Lecture.first.instance_variable_get(:@users)
  end

  def test_old_instance_variable_is_removed_after_renaming
    m2.do
    assert_not Lecture.first.instance_variable_defined?(:@users)
    assert_nil Lecture.first.instance_variable_get(:@users)
  end
end

################## rename attributes


class TestMigrationRenameAttributes < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture2.fill_with_examples
  end

  def m3
    MaglevRecord::Migration.new(Time.now, "rename attribute") do
      def up
        Lecture2.rename_attribute(:lecturer , :lecturers) {
          |lecturer|
          [lecturer]
        }
      end
    end
  end

  def test_rename_attribute_with_block
    lecturer = Lecture2.first.lecturer
    m3.do
    assert_equal Lecture2.first.lecturers, [lecturer]
  end

  def test_attr_lecturer_exists
    assert_not_nil Lecture2.first.lecturer
  end

  def m4
    MaglevRecord::Migration.new(Time.now, "rename attribute") do
      def up
        Lecture2.rename_attribute(:users , :attendees)
      end
    end
  end

  def test_rename_attribute
    users = Lecture2.first.users
    m4.do
    assert_equal Lecture2.first.attendees, users
  end

  def test_attr_users_exists
    assert_not_nil Lecture2.first.users
    assert_not_equal Lecture2.first.users, []
  end

end

################## rename classes

class TestMigrationRenameClass < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture3.fill_with_samples
  end

  def migration
    MaglevRecord::Migration.new(Time.now, "rename attribute") do
      def up
        rename_class Lecture3, :Lecture4
      end
    end
  end

  def test_objects_are_in_renamed_class
    obj = Lecture3.first
    migration.do
    assert_equal Lecture4.first, obj
  end

  def test_class_has_objects
    assert_not_equal Lecture3.all, []
  end

  def test_renamed_class_has_no_objects
    migration.up
    assert_equal Lecture3.all, []
  end

  def test_unrenamed_classes_have_distinct_objects
    Lecture3.each{ |lecture3|
      assert_not_include? Lecture4.all, lecture3
    }
  end

  def test_objects_are_of_renamed_class
    assert_equal Lecture3.first.class, Lecture3
    migration.do
    assert_equal Lecture4.first.class, Lecture4
  end

  def test_objects_are_not_of_original_class
    assert_equal Lecture3.first.class, Lecture3
    migration.do
    assert_not_equal Lecture4.first.class, Lecture3
  end

end


