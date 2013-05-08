require "more_asserts"
require "migration/operation_setup"

class FastSnapshotTest < Test::Unit::TestCase

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
    @snapshot0 = snapshot
  end

  def snapshot0
    @snapshot0
  end

  def teardown
    teardown_migration_operations
  end

  def remove_class(*classes)
    Maglev.persistent do
      classes.each { |cls|
        Object.remove_const cls.name
        def cls.exists?
          false
        end
      }
    end
  end

  def test_removed_class
    remove_class Lecture
    assert_raise(NameError) {
      Lecture
    }
    assert_not_include? Object.constants, "Lecture"
  end

end

class LocalClassSnapshotTest < FastSnapshotTest

  def test_lecture_classes_exist
    ['Lecture', 'Lecture2', 'Lecture3', 'Lecture4'].each { |lecture_name|
      assert_include? snapshot.class_names, lecture_name
    }
  end

  def test_class_removed
    remove_class Lecture
    assert_equal 1, changes.removed_classes.size
  end

  def test_class_is_not_in_snashot_when_removed
    remove_class Lecture
    assert_not_include? snapshot.class_names, "Lecture"
  end

  def test_class_is_in_snapshot0_when_removed
    remove_class Lecture
    assert_include? snapshot0.class_names, "Lecture"
  end

  def test_removed_class_is_in_changes
    remove_class Lecture4
    assert_equal ["Lecture4"], changes.removed_class_names
    assert_not changes.nothing_changed?
  end

end

class LocalAttibuteAddSnapshotTest < FastSnapshotTest
  def test_new_attribute
    Lecture.attr_accessor :test_accessor
    assert_equal ["Lecture"], changes.changed_class_names
    assert_equal [:test_accessor], changes.changed_classes[0].new_attr_accessors
    assert_not changes.nothing_changes?
  end
end

class LocalAttributeRemoveSnapshotTest < FastSnapshotTest

  def setup
    super
    Lecture2.attr_accessor :test_accessor2
    snapshot!
    Lecture2.delete_attribute :test_accessor2
  end

  def test_removed_attribute
    assert_equal ["Lecture2"], changes.changed_class_names
    assert_equal [:test_accessor2], changes.changed_classes[0].removed_attr_accessors
  end

  def test_accessor_in_first_snapshot
    assert_include? snapshot0[Lecture2].attr_accessors, :test_accessor2
  end

  def test_accessor_not_in_second_snapshot
    assert_not_include? snapshot[Lecture2].attr_accessors, :test_accessor2
  end
end


