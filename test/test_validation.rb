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
  
  def test_save_excl_invalid_throws_error
    book = invalid_model
    
    @catch = false
    begin
      book.save!
    rescue StandardError
      @catch = true
    end
    
    assert @catch
  end

  def test_save_invalid_returns_false
    book = invalid_model
    assert !book.save
  end

  def test_save_skip_validation
    book = invalid_model
    assert book.save(:validate => false)
  end
end

