require "snapshot/test_snapshot"

class ClassSnapshotTest < SnapshotTest

  def test_new_class
    changes = compare('', class_string('MyTestClass'))
    assert_not_equal [], changes.new_classes
    classdiv = changes.new_classes[0]
    assert_equal classdiv.class_name, 'MyTestClass'
    assert_equal classdiv.class, MyTestClass
  end

  def test_class_removed_from_file_but_still_in_stone
    changes= compare(class_string('MyTestClass2'), '')
    assert_not_equal [],  changes.removed_classes
    classdiv = changes.removed_classes[0]
    assert_equal classdiv.class_name, 'MyTestClass2'
    assert_nil classdiv.class, 'this class was removed: there should not be a reference to it'
  end

end

