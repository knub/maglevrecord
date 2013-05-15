require "snapshot/test_snapshot.fast.rb"

class LocalMethodSnapshotTest < FastSnapshotTest

  def setup
    super
    def Lecture.removed_method;end
    Lecture.class_eval "def removed_i_method;end"
    snapshot!
    def Lecture.new_method;end
    Lecture.remove_method :removed_i_method
    Lecture.remove_method :removed_method
  end

  def test_Lecture_has_new_method
    assert_include? Lecture.instance_methods, "new_i_method"
    assert_include? Lecture.methods, "new_method"
  end

  def test_new_method
    assert_include? snapshot[Lecture].class_methods, "new_method"
    assert_include? snapshot[Lecture].instance_methods, "new_i_method"
  end

  def test_Lecture_has_no_removed_method
    assert_not_inlcude? Lecture.instance_methods "removed_i_method"
    assert_not_inlcude? Lecture.methods "removed_method"
  end

  def test_has_no_removed_method
    assert_not_include? snapshot[Lecture].class_methods, "new_method"
    assert_not_include? snapshot[Lecture].instance_methods, "new_i_method"
  end

  def test_Lecture3_has_methods_of_Lecture
    assert_include? Lecture3.instance_methods, "new_i_method"
    assert_include? Lecture3.methods, "new_method"
  end

  def test_Lecture3_has_no_new_method_in_snapshot
    assert_not_include? snapshot[Lecture3].class_methods, "new_method"
    assert_not_include? snapshot[Lecture3].instance_methods, "new_i_method"
  end

  def test_Lecture3_has_no_removed_method
    assert_not_include? Lecture3.instance_methods, "removed_i_method"
    assert_not_include? Lecture3.methods, "removed_method"
  end

  def test_Lecture3_has_no_removed_method_in_snapshot
    assert_not_include? snapshot[Lecture3].class_methods, "removed_method"
    assert_not_include? snapshot[Lecture3].instance_methods, "removed_i_method"
  end

  def test_only_Lecture_changed
    assert_equal [], changes.new_classes
    assert_equal [], changes.removed_classes
    assert_equal 1, changes.changed_classes.size, "#{changes.changed_classes.size}"
  end

  def lecture_change
    changes.changed_classes.first
  end

  def test_removed_instance_method_changed_Lecture
    assert_equal ["removed_i_method"], lecture_changes.removed_instance_methods
  end

  def test_removed_class_method_changed_Lecture
    assert_equal ["removed_method"], lecture_changes.removed_class_methods
  end

  def test_new_class_method_changed_Lecture
    assert_equal ["new_method"], lecture_changes.new_class_methods
  end

  def test_new_instance_method_changed_Lecture
    assert_equal ["new_i_method"], lecture_changes.new_instance_methods
  end

end
