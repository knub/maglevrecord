require "test/unit"
require "maglev_record"
require "example_model"

class ValidationTest < Test::Unit::TestCase

  def setup
    Maglev.abort_transaction
    Book.new(:title => "Harry Potter and the Philosopher's stone", :author => "Joanne K. Rowling")
    Book.new(:title => "Harry Potter and the Chamber of Secrets", :author => "Joanne K. Rowling")
    MaglevRecord.save
  end

  def teardown
    Book.clear
    MaglevRecord.save
  end

  def test_reset
    book = Book.find { |b| b.title == "Harry Potter and the Philosopher's stone" }
    book.author = "J. R. R. Tolkien"
    book.title = "The Lord of the Rings"

    MaglevRecord.reset
    assert_not_nil Book.find { |b| b.title == "Harry Potter and the Philosopher's stone" }
  end

  def invalid_model
    Book.new(:author => "J. R. R. Tolkien", :title => "LotR")
  end

  def test_validation_fails
    book = invalid_model
    assert !book.valid?
    assert book.invalid?
  end

  def test_errors_not_empty
    book = invalid_model
    book.valid?
    assert book.errors.count > 0
  end

  def test_validation_succeeds
    book = Book.new(:author => "J. R. R. Tolkien", :title => "Harry Potter and the Philosopher's stone")
    assert book.valid?
    assert !book.invalid?
  end

end

