require "snapshot/test_snapshot.fast.rb"

class LocalAttibuteAddSnapshotTest < FastSnapshotTest
  def test_new_attribute
    Lecture.attr_accessor :test_accessor
    assert_equal ["Lecture"], changes.changed_class_names
    assert_equal [:test_accessor], changes.changed_classes[0].new_attr_accessors
    assert_not changes.nothing_changed?
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
