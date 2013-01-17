require "test/unit"
require "maglev_record"
require "rooted_example_model"

class QueryInterfaceTest < Test::Unit::TestCase

  def setup
    RootedBook.new(:title => "Harry Potter and the Philosopher's stone", :author => "Joanne K. Rowling")
    RootedBook.new(:title => "Harry Potter and the Chamber of Secrets", :author => "Joanne K. Rowling")
    RootedBook.new(:title => "Harry Potter and the Prisoner of Azkaban", :author => "Joanne K. Rowling")
    RootedBook.new(:title => "Harry Potter and the Goblet of Fire", :author => "Joanne K. Rowling")
    RootedBook.new(:title => "Harry Potter and the Order of the Phoenix", :author => "Joanne K. Rowling")
    RootedBook.new(:title => "Harry Potter and the Half-blood Prince", :author => "Joanne K. Rowling")
    RootedBook.new(:title => "Harry Potter and the Deathly Hallows", :author => "Joanne K. Rowling")
    RootedBook.new(:title => "The Magician's Guild", :author => "Trudi Canavan")
  end

  def teardown
    RootedBook.clear
  end

  def test_size_returns_correct_amount_of_books
    assert_equal RootedBook.size, 8
  end

  def test_clear_clears_the_database
    assert RootedBook.size > 0
    RootedBook.clear
    assert RootedBook.size == 0
  end

# commented out, because it only works with the the new hash implementation
#  def test_first_returns_the_first_book
#    assert RootedBook.first.title.include? "Philosopher"
#  end

  def test_normal_enumerable_methods_work
    assert_equal 7, RootedBook.count { |b| b.author == "Joanne K. Rowling" }
  end

  def test_work_on_real_objects
    book = RootedBook.first
    book.author = "William Shakespeare"
    assert_equal RootedBook.first.author, "William Shakespeare"
  end

end
