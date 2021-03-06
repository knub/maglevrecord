require "snapshot/test_snapshot.slow"

class AttrSnapshotTest < SnapshotTest

  def self.changes
    @changes
  end

  as_instance_method :changes

  def self.startup
    super
    clean
    @changes = compare(
      class_string('MyTestClass2', 'attr_accessor :no_value, :lala'),
      class_string('MyTestClass2', 'attr_accessor :students, :lala'))
  end

  def self.shutdown
    super
    clean
  end

  def test_snapshot_without_error
    assert_not_nil changes
  end

  def test_no_class_removed
    assert_equal changes.removed_classes, []
  end

  def test_class_changed
    assert_equal changes.changed_classes.size, 1
  end

  def test_no_class_was_added
    assert_equal [], changes.new_classes
  end

  def changed_class
    assert_not_nil changes.changed_classes[0], 'a class must have changed'
    changes.changed_classes[0]
  end

  def test_accessor_added
    assert_equal changed_class.new_attributes, ["students"]
  end

  def test_accessor_removed
    assert_equal changed_class.removed_attributes, ["no_value"]
  end

end


