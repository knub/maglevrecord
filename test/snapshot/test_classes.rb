require "snapshot/test_snapshot"

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
