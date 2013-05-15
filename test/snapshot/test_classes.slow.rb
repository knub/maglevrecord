require "snapshot/test_snapshot"

class ClassSnapshotTest < SnapshotTest

  def setup
    super
    clean
  end

  def teardown
    super
    clean
  end

  def test_new_class
    changes = compare('', class_string('MyTestClass', 'def x;end'))
    assert_equal 1, changes.new_classes.size
    classdiv = changes.new_classes[0]
    assert_equal classdiv.class_name, 'MyTestClass'
    assert_equal classdiv.snapshot_class, MyTestClass
  end

  def test_class_removed_from_file_but_still_in_stone
    changes= compare(class_string('MyTestClass2', 'def x;end'), '')
    assert_equal 1,  changes.removed_classes.size
    classdiv = changes.removed_classes[0]
    assert_equal classdiv.class_name, 'MyTestClass2'
    assert_equal classdiv.snapshot_class, MyTestClass2
  end

end

