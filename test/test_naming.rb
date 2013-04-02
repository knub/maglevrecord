require "more_asserts"
require "maglev_record"
require "example_model"

class NamingTest < Test::Unit::TestCase

  def rooted_example_book
    RootedBook.example
  end

  def unrooted_example_book
    UnrootedBook.example
  end

  def test_models_respond_to_model_name
    [rooted_example_book, unrooted_example_book].each do |b|
      assert b.class.respond_to?(:model_name)
    end
    assert_equal "RootedBook", rooted_example_book.class.model_name
    assert_equal "UnrootedBook", unrooted_example_book.class.model_name
  end
end