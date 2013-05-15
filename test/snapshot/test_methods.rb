require "snapshot/test_snapshot"

class FastMethodSnapshotTestBase < FastSnapshotTest
  def setup
    super
    def Lecture.removed_method;end
    Lecture.class_eval{def removed_i_method;end}
    Lecture.attr_accessor :accessor1
    snapshot!
    def Lecture.new_method;end
    Lecture.class_eval{def new_i_method;5;end}
    Lecture.remove_method :removed_i_method
    Lecture.singleton_class.remove_method :removed_method
  end

  def test
    Lecture.fill_with_examples
    assert_equal 5, Lecture.first.new_i_method
  end
end

class FastMethodSnapshotEnvironmentTest < FastMethodSnapshotTestBase

  # depends on FastMethodSnapshotTestBase

  def test_Lecture_has_new_method
    assert_include? Lecture.instance_methods, "new_i_method"
    assert_include? Lecture.methods, "new_method"
  end

  def test_Lecture_has_no_removed_method
    assert_not_include? Lecture.instance_methods, "removed_i_method"
    assert_not_include? Lecture.methods, "removed_method"
  end

  def test_Lecture3_has_methods_of_Lecture
    assert_include? Lecture3.instance_methods, "new_i_method"
    assert_include? Lecture3.methods, "new_method"
  end

  def test_Lecture3_has_no_removed_method
    assert_not_include? Lecture3.instance_methods, "removed_i_method"
    assert_not_include? Lecture3.methods, "removed_method"
  end
end

class FastMethodSnapshotTest < FastMethodSnapshotTestBase

  # depends on FastMethodSnapshotEnvironmentTest

  def test_Lecture_has_new_method
    assert_include? snapshot[Lecture].class_methods, "new_method"
    assert_include? snapshot[Lecture].instance_methods, "new_i_method"
  end

  def test_Lecture_has_no_removed_method
    assert_not_include? snapshot[Lecture].class_methods, "removed_method"
    assert_not_include? snapshot[Lecture].instance_methods, "removed_i_method"
  end

  def test_Lecture3_has_no_new_method
    assert_not_include? snapshot[Lecture3].class_methods, "new_method"
    assert_not_include? snapshot[Lecture3].instance_methods, "new_i_method"
  end
  def test_Lecture3_has_no_removed_method
    assert_not_include? snapshot[Lecture3].class_methods, "removed_method"
    assert_not_include? snapshot[Lecture3].instance_methods, "removed_i_method"
  end
end

class FastMethodChangeTest < FastMethodSnapshotTestBase

  # depends on FastMethodSnapshotTest

  def test_only_Lecture_changed
    assert_equal [], changes.new_classes
    assert_equal [], changes.removed_classes
    assert_equal 1, changes.changed_classes.size, "#{changes.changed_classes.size}"
  end

  def lecture_changes
    changes.changed_classes.first
  end

  def test_removed_instance_method
    assert_equal ["removed_i_method"], lecture_changes.removed_instance_methods
  end

  def test_removed_class_method
    assert_equal ["removed_method"], lecture_changes.removed_class_methods
  end

  def test_new_instance_method
    assert_equal ["new_i_method"], lecture_changes.new_instance_methods
  end

  def test_new_class_method
    assert_equal ["new_method"], lecture_changes.new_class_methods
  end

end

class FastMethodVSAcessorChangeTest < FastMethodChangeTest

  def setup
    super
    Lecture.remove_method :accessor1
    Lecture.remove_method :accessor1=
    Lecture.attr_accessor :accessor2
  end

end

class FastMethodVSAcessorSnapshotTest < FastMethodSnapshotTestBase

  def setup
    super
    Lecture.remove_method :accessor1
    Lecture.remove_method :accessor1=
    Lecture.attr_accessor :accessor2
  end

end

# TODO add test for attr becomes method and reverse
