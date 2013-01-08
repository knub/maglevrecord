require "test/unit"
require "maglev_record"
require "example_model"

class MagLevRecordTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def model
    Book.dummy
  end

  def test_the_truth
    assert true
  end
end
