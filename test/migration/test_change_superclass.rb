require "migration/operation_setup"

class ChangeSuperclassTest < Test::Unit::TestCase

  def setup
    setup_migration_operations
    cls.fill_with_examples
    @example = cls.first
    assert_not_equal Lecture2, cls.superclass
    assert_equal Lecture, cls.superclass
    cls.change_superclass_to Lecture2
  end

  def cls
    Lecture3
  end

  def teardown
    teardown_migration_operations
  end

  def test_superclass_has_changed
    assert_equal Lecture2, cls.superclass
  end

  def test_objects_are_still_of_that_class
    assert_equal @example.class, cls
  end

end

class MigrationChangesSuperclassTest < Test::Unit::TestCase

  def setup
    setup_migration_operations
  end

  def teardown
    teardown_migration_operations
  end

  def test_migrating_superclass_change
    assert_not_equal Lecture2, Lecture3.superclass
    assert_not_equal Object, Lecture3.superclass
    MaglevRecord::Migration.new(Time.now, "change_superclass") do
      def up
        Lecture3.change_superclass_to Lecture2
      end
    end.do
    assert_equal Lecture3.superclass, Lecture2
  end

  def test_superclass_does_not_exist
    original_superclass = Lecture3.superclass
    assert_raises(NameError){ SuperclassThatDoesNotExist }
    MaglevRecord::Migration.new(Time.now, "change_superclass") do
      def up
        Lecture3.change_superclass_to SuperclassThatDoesNotExist
      end
    end.do
    assert_equal original_superclass, Lecture3.superclass
  end

  def test_class_does_not_exist
    assert_raises(NameError){ ClassThatDoesNotExist }
    MaglevRecord::Migration.new(Time.now, "change_superclass") do
      def up
        ClassThatDoesNotExist.change_superclass_to Lecture3
      end
    end.do
    assert_raises(NameError){ ClassThatDoesNotExist }
  end

  def test_both_classes_do_not_exist
    MaglevRecord::Migration.new(Time.now, "change_superclass") do
      def up
        ClassThatDoesNotExist.change_superclass_to SuperclassThatDoesNotExist
      end
    end.do
    assert_raises(NameError){ ClassThatDoesNotExist }
    assert_raises(NameError){ SuperclassThatDoesNotExist }

  end
end












