require "test/unit"
require "maglev_record"
require "example_model"

class QueryInterfaceTest < Test::Unit::TestCase

  def setup
    RootedBook.clear
    RootedBook.create(:title => "Harry Potter and the Philosopher's stone", :author => "Joanne K. Rowling")
    RootedBook.create(:title => "The Hobbit", :author => "J. R. R. Tolkien")
    RootedBook.create(:title => "The Lord of the Rings", :author => "J. R. R. Tolkien")
    RootedBook.create(:title => "Charlie and the Chocolate Factory", :author => "Roald Dahl")
    RootedBook.create(:title => "A Christmas Carol", :author => "Charles Dickens")
  end

  def test_all_returns_all_books
    all_books = RootedBook.all
    assert_equal all_books.class, Array
    assert_equal all_books.size, 5
  end

  def test_size_returns_correct_amount_of_books
    assert_equal RootedBook.size, 5
  end

  def test_first_returns_the_first_book
    assert RootedBook.first.title.include? "Philosopher"
  end

  def test_normal_enumerable_methods_work
    assert_equal 2, RootedBook.count { |b| b.author == "J. R. R. Tolkien" }
  end

  def test_work_on_real_objects
    book = RootedBook.first
    book.author = "William Shakespeare"
    assert_equal RootedBook.first.author, "William Shakespeare"
  end

  def test_find_object_by_id
    book = RootedBook.all[2]
    assert_equal book, RootedBook.find_by_objectid(book.object_id)
  end

end
