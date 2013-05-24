require "migration/operation_setup"

class RemoveSuperclassTest < Test::Unit::TestCase

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











