require "migration/operation_setup"

class RemoveSuperclassTest < Test::Unit::TestCase

  def setup
    setup_migration_operations
    cls.fill_with_examples
    cls.remove_superclass
  end

  def cls
    Lecture3
  end

  def teardown
    teardown_migration_operations
  end

  def test_superclass_is_object
    assert_equal Object, cls.superclass
  end

  def test_object_can_inherit_again
    assert_equal cls, Object.module_eval(cls.name)
    Object.module_eval "class #{cls.name} < Lecture2; end"
    assert_equal cls.superclass, Lecture2
  end

end











