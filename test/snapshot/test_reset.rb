require "migration/operation_setup"

class ResetTest < Test::Unit::TestCase

  def setup
    setup_migration_operations
  end

  def teardown
    teardown_migration_operations
  end

  def test_reset_an_no_methods_remain
    Lecture.reset
    assert_equal [], Lecture.methods(false)
    assert_equal [], Lecture.instance_methods(false)
  end

  def test_subclasses_do_not_dfelete_superclass_methods
    assert_equal Lecture, Lecture3.superclass
    Lecture3.reset
    assert_equal [], Lecture3.instance_methods(false)
    assert_not_equal [], Lecture.instance_methods(false)
  end

  def test_also_subclasses_lose_methods
    Lecture3.reset
    assert_equal [], Lecture3.methods(false)
    assert_not_equal [], Lecture.methods(false)
  end

  def test_methods_can_be_restored
    m = Lecture3.methods(false)
    im = Lecture3.instance_methods(false)
    restore = Lecture3.reset
    restore.call
    assert_equal m, Lecture3.methods(false)
    assert_equal im, Lecture3.instance_methods(false)
  end

  def test_even_new_methods_get_restored
    def Lecture.something
      5
    end
    restore = Lecture.reset
    assert_raises(NoMethodError){ Lecture.something }
    restore.call
    assert_equal 5, Lecture.something
  end

  def test_accessors
    Lecture.attr_accessor :lala
    assert_include? Lecture.attributes, "lala"
  end

  def test_attributes_get_removed
    Lecture.attr_accessor :lala
    Lecture.reset
    assert_equal Lecture.attributes, []
  end

  def test_attributes_get_restored
    Lecture.attr_accessor :lala
    restore = Lecture.reset
    restore.call
    assert_include? Lecture.attributes, "lala"
  end
end
