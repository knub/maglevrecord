require "test/unit"
require "maglev_record"
require "example_model"

class ValidationTest < Test::Unit::TestCase

  def setup
    [
      Book.new(:title => "Harry Potter and the Philosopher's stone", :author => "Joanne K. Rowling"),
      Book.new(:title => "Harry Potter and the Chamber of Secrets", :author => "Joanne K. Rowling")
    ].each do |book|
      book.save
    end
  end

  def teardown
    Book.clear
  end

  def test_reset_single_attribute
    book = Book.find { |b| b.title == "Harry Potter and the Philosopher's stone" }
    book.author = "J. R. R. Tolkien"
    book.reset_author!
    assert_equal book.author, "Joanne K. Rowling"
  end

  def test_reset_all_attributes
    book = Book.find { |b| b.title == "Harry Potter and the Philosopher's stone" }
    book.author = "J. R. R. Tolkien"
    book.title = "The Lord of the Rings"
    book.reset!
    assert_equal book.author, "Joanne K. Rowling"
    assert_equal book.title, "Harry Potter and the Philosopher's stone"
  end

end

