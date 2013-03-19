require "more_asserts"
require "maglev_record"
require "example_model"

class ValidationTest < Test::Unit::TestCase

  def setup
    MaglevRecord.reset
    RootedBook.clear
    MaglevRecord.save
  end

  # TODO
  # def test_reset
  #   book = Book.find { |b| b.title == "Harry Potter and the Philosopher's stone" }
  #   book.author = "J. R. R. Tolkien"
  #   book.title = "The Lord of the Rings"

  #   MaglevRecord.reset
  #   assert_not_nil Book.find { |b| b.title == "Harry Potter and the Philosopher's stone" }
  # end

  def test_validation_works
    book = RootedBook.new(:author => "Book")
    assert book.valid?
    assert_not book.invalid?
    MaglevRecord.save
  end

  def test_validation_fails
    book = RootedBook.new()
    assert !book.valid?
    assert book.invalid?
    MaglevRecord.save
  end

  def test_errors_not_empty
    book = RootedBook.new()
    book.valid?
    assert book.errors.count > 0
  end

end

