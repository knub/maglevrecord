require "more_asserts"
require "maglev_record"
require "example_model"
require "timecop"

class ModelTimestampTest < Test::Unit::TestCase

  def test_time
    @test_time ||= Time.local(2008, 9, 1, 10, 5, 0)
  end
  def test_created_at
    Timecop.freeze(test_time)
    model = RootedBook.example
    assert_equal model.created_at, test_time
  end

  def teardown
    Timecop.return
  end


end