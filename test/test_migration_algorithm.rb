require "test/unit"
require "maglev_record"

class TestMigrationList < Test::Unit::TestCase
  
  class ML < MaglevRecord::MigrationList
  end

  class ML2 < ML
  end

  def setup
    @l = ML.new
  end

  def teardown
    ML.clear
  end

  def l
    @l
  end

  def test_l_was_created_last
    assert_equal ML.last, l
  end

  def test_clear_clears_all_ML
    ML.clear
    assert_not_equal ML.last, l
  end

  def test_ml_clear_does_not_clear_ml
    l2 = ML2.new
    ML2.clear
    assert_not_equal ML2.last, l2
    assert_equal ML.last, l
  end

  def test_lists_link_to_last_list
    l1 = ML.last
    l2 = ML.new
    l3 = ML.new
    l4 = ML.new
    assert_equal l1, l2.last_migration_list
    assert_equal l2, l3.last_migration_list
    assert_equal l3, l4.last_migration_list
  end

end
