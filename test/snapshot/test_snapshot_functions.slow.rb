require "snapshot/test_snapshot"

class AttrSnapshotTest < SnapshotTest

  def self.changes
    @changes
  end

  as_instance_method :changes

  def self.startup
    super
    clean
    @changes = compare(
       class_string('MyTestClass2', 'def exists1;end; def exists;end;def self.cls1;end;def self.cls;end;'),
       class_string('MyTestClass2', 'def exists2;end; def exists;end;def self.cls2;end;def self.cls;end;'))
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

  def test_method_added
    assert_equal changed_class.new_methods, [:exists2]
  end

  def test_method_removed
    assert_equal changed_class.removed_methods, [:exist1]
  end

  def test_class_method_added
    assert_equal changed_class.new_class_methods, [:cls2]
  end

  def test_class_method_removed
    assert_equal changed_class.removed_class_methods, [:cls1]
  end

end




