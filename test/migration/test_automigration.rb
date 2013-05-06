require "snapshot/test_snapshot.fast"


class MigrationStringTest < FastSnapshotTest

  def setup
    super
    Lecture2.attr_accessor :lecturer
    snapshot!
  end

  def assert_migration_string(string, message = nil)
    if message.nil?
      assert_equal string, changes.migration_string
    else
      assert_equal string, changes.migration_string, message
    end
  end

  def test_no_migration_string_if_nothing_happens
    assert_migration_string ""
  end

  def test_class_removed
    remove_class Lecture
    assert_migration_string 'delete_class Lecture'
  end

  def test_two_classes_removed
    remove_class Lecture2, Lecture3
    assert_migration_string "delete_class Lecture2\ndelete_class Lecture3"
  end

  def test_rename_class_is_remove_and_add
    #fail('todo')
  end

  def test_added_attr_accessor
    assert_not_include? Lecture3.instance_methods, "test_accessor"
    Lecture3.attr_accessor :test_accessor
    assert_migration_string ""
  end

  def test_removed_attr_accessor
    Lecture2.delete_attribute(:lecturer)
    assert_migration_string "Lecture2.delete_attribute(:lecturer)"
  end

  def test_remove_accessor_is_remove_and_add
    Lecture2.delete_attribute(:lecturer)
    Lecture2.attr_accessor :testitatetue
    assert_migration_string "Lecture2.rename_attribute(:lecturer, :testitatetue)"
  end

  def test_add_class_requires_no_migration_string
    #fail('todo')
  end

end



