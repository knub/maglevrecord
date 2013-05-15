require "snapshot/test_snapshot"

class MigrationStringTest < FastSnapshotTest

  def setup
    super
    Lecture2.attr_accessor :lecturer
    def Lecture.class_method1;end
    Lecture.class_eval{def instance_method1;end}
    snapshot!
  end

  def assert_migration_string(string, *args)
    assert_equal string, changes.migration_string(*args)
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
    remove_class Lecture4
    snapshot! # Lecture3 exists
    redefine_migration_classes
    remove_class Lecture3 # Lecture4 exists, Lecture3 is removed
    assert_migration_string "rename_class Lecture3, :Lecture4"
  end

  # TODO string when attributes renamed when class renamed
  # TODO string when many things happen
  # TODO lecture -> lectures map to list block

  def test_added_attr_accessor
    assert_not_include? Lecture3.instance_methods, "test_accessor"
    Lecture3.attr_accessor :test_accessor
    assert_migration_string "#new accessor :test_accessor of Lecture3"
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
    remove_class Lecture3, Lecture4
    snapshot!
    redefine_migration_classes
    migration_string = "    #new class: Lecture3\n    #new class: Lecture4"
    assert_migration_string migration_string, 4
  end

  def test_add_class_method
    def Lecture.class_method2;end
    assert_migration_string "#new class method: Lecture.class_method2"
  end

  def test_add_instance_method
    Lecture.class_eval{def instance_method2;end}
    assert_migration_string "#new instance method: Lecture.new.instance_method2"
  end

  def test_remove_class_method
    Lecture.singleton_class.remove_method :class_method1
    assert_migration_string 'Lecture.remove_class_method :class_method1'
  end

  def test_remove_instance_method
    Lecture.remove_method :instance_method1
    assert_migration_string 'Lecture.remove_instance_method :instance_method1'
  end
end

class MethodBecomesAccessorTest < FastSnapshotTest
  def setup
    super
    Lecture.define_method :access do end
    Lecture.define_method :access= do |x| end
    snapshot!
    Lecture.attr_accessor :access
    Lecture.fill_with_examples
  end

  def test_can_save_state
    Lecture.first.access= 3
    assert_equal 3, Lecture.first.access
  end

  def test_do_not_remove_accessor_methods
    assert_migration_string, "#method :access of Lecture is now an accessor\n"+
                             "#method :access= of Lecture is now an accessor"
  end
end

class AccessorBecomesMethodTest < FastSnapshotTest
  def setup
    super
    Lecture.attr_accessor :access
    snapshot!
    Lecture.delete_attribute :access
    Lecture.define_method :access do @x end
    Lecture.define_method :access= do |x| @x = x end
    Lecture.fill_with_examples
  end

  def test_can_save_state
    Lecture.first.access= 3
    assert_equal 3, Lecture.first.access
  end

  def test_do_not_remove_accessor_methods
    assert_migration_string, "#accessor :access of Lecture is now a method\n"+ 
                             "#accessor :access= of Lecture is now a method"
  end
end


