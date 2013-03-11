require "test/unit"
require "maglev_record"
puts "Before requiring example_model."
require "example_model"

class ActiveModelLikeInterfaceTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def model
    Book.dummy
  end

  def test_getters_setters
    book = self.model
    book.author = "Another author"
    assert_equal book.author, "Another author"
  end

  def test_to_params_returns_id
    book = self.model
    assert_equal book.id book.to_param
  end
end
