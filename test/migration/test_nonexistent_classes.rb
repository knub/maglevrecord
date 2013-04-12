####
#
#   Test Cases for non existent classes:
#
#   rename and delete:
#
#     - instance variables
#
#     - attributes
#
#     - classes
#




require "maglev_record"
require "more_asserts"
require 'time'


class TestMigrationRenameAttributes < Test::Unit::TestCase

  def assert_NonExistentClass_not_present
    assert_raise(NameError) {
      NonExistentClass
    }
  end

  def test_nonexistent_class_is_not_present
    assert_NonExistentClass_not_present
  end

  ################## rename instance variables

  def migration_rename_inst_var
    MaglevRecord::Migration.new(Time.now, "rename instance variable") do
      def up
        NonExistentClass.rename_instance_variable(:@lecturer , :@lecturers)
      end
    end
  end

  def migration_rename_inst_var_block
    MaglevRecord::Migration.new(Time.now, "rename instance variable") do
      def up
        NonExistentClass.rename_instance_variable(:@lecturer , :@lecturers) {
          |lecturer|
          raise "This should never happen"
        }
      end
    end
  end

  def test_rename_instance_variable_with_block
    migration_rename_inst_var_block.do
    assert_NonExistentClass_not_present
  end

  def test_rename_instance_variable
    migration_rename_inst_var.do
    assert_NonExistentClass_not_present
  end

  ################## rename others

  def test_rename_attribute
    migration = MaglevRecord::Migration.new(Time.now, "rename instance variable") do
      def up
        NonExistentClass.rename_instance_variable(:@lecturer , :@lecturers)
      end
    end
    migration.do
    assert_NonExistentClass_not_present
  end

  def test_rename_class
    migration = MaglevRecord::Migration.new(Time.now, "rename instance variable") do
      def up
        rename_class NonExistentClass2, :NonExistentClass
      end
    end
    migration.do
    assert_NonExistentClass_not_present
  end

  ################## remove

  def test_delete_instance_variable
    migration = MaglevRecord::Migration.new(Time.now, "remove instance variable") do
      def up
        NonExistentClass.delete_instance_variable(:@lecturer)
      end
    end
    migration.do
    assert_NonExistentClass_not_present
  end

  def test_delete_attribute
    migration = MaglevRecord::Migration.new(Time.now, "remove attribute") do
      def up
        NonExistentClass.delete_attribute(:lecturer)
      end
    end
    migration.do
    assert_NonExistentClass_not_present
  end

  def test_delete_class
    migration = MaglevRecord::Migration.new(Time.now, "remove class") do
      def up
        delete_class(NonExistentClass)
      end
    end
    migration.do
    assert_NonExistentClass_not_present
  end

end

