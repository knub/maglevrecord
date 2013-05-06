require "more_asserts"
require "migration/operation_setup"

class AutoMigrationSourceTest < Test::Unit::TestCase

  def snapshot
    MaglevRecord::Snapshot.new
  end

  def changes
    snapshot.changes_since snapshot0
  end

  def setup
    setup_migration_operations
    snapshot!
  end

  def snapshot!
    snapshot0 = snapshot
  end

  attr_accessor :snapshot0

  def teardown
    teardown_migration_operations
  end

  def remove_class(*classes)
    cls.each { |cls|
      Object.remove_const cls.name
    }
  end

  def assert_migration_string(string, message = nil)
    if message.nil?
      assert_equal string, changes.migration_string
    else
      assert_equal string, changes.migration_string, message
    end
  end

  def test_class_removed
    remove_class Lecture
    assert_migration_string 'delete_class :Lecture'
  end

  def test_two_classes_removed
    remove_class Lecture2, Lecture3
    assert_migration_string "delete_class Lecture2\ndelete_class Lecture3"
  end

  def test_rename_class_is_remove_and_add
  end

  def test_added_attr_accessor
  end

  def test_removed_attr_accessor
  end

  def test_remove_accessor_is_remove_and_add
  end

  def test_add_class_requires_no_migration_string
  end

end



