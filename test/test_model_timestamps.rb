require "more_asserts"
require "maglev_record"
require "example_model"
require "timecop"

class ModelTimestampTest < Test::Unit::TestCase

  def test_time
    @test_time ||= Time.local(2008, 9, 1, 10, 5, 0)
  end

  def setup
    Timecop.freeze(test_time)
  end
  def teardown
    Timecop.return
  end

  def test_created_at
    model = RootedBook.example
    assert_equal model.created_at, test_time
  end

  def test_updated_at
    model = RootedBook.example
    Timecop.freeze(test_time + 10)
    model.author = 'Another author'
    assert_equal model.updated_at, test_time + 10
  end
end
