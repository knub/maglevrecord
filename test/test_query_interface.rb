require "test/unit"
require "maglev_record"
require "example_model"

class QueryInterfaceTest < Test::Unit::TestCase

  def setup
    [
      Book.new(:title => "Harry Potter and the Philosopher's stone", :author => "Joanne K. Rowling"),
      Book.new(:title => "Harry Potter and the Chamber of Secrets", :author => "Joanne K. Rowling"),
      Book.new(:title => "Harry Potter and the Prisoner of Azkaban", :author => "Joanne K. Rowling"),
      Book.new(:title => "Harry Potter and the Goblet of Fire", :author => "Joanne K. Rowling"),
      Book.new(:title => "Harry Potter and the Order of the Phoenix", :author => "Joanne K. Rowling"),
      Book.new(:title => "Harry Potter and the Half-blood Prince", :author => "Joanne K. Rowling"),
      Book.new(:title => "Harry Potter and the Deathly Hallows", :author => "Joanne K. Rowling"),
      Book.new(:title => "The Magician's Guild", :author => "Trudi Canavan")
    ].each do |book|
      book.save
    end
  end

  def teardown
    Book.clear
  end

  def test_size_returns_correct_amount_of_books
    #assert_equal Book.size, 8
  end

  def test_clear_clears_the_database
    #assert Book.size > 0
    Book.clear
    #assert Book.size == 0
  end

  def test_first_returns_the_first_book
    puts Book.first
    #assert Book.first.title.include? "Philosopher"
  end

  def test_normal_collection_methods_work
    #assert_equal 7, Book.select do |book| book.author == "Joanne K. Rowling" end.size
  end

  def test_work_on_real_objects
    book = Book.first
    book.author = "William Shakespeare"
    #assert_equal Book.first.author, "William Shakespeare"
  end

  def test_reset_works
    book = Book.first
  end

end
