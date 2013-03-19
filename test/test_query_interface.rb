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

  def test_size_returns_correct_amount_of_books
    assert_equal RootedBook.size, 5
  end

  # def test_first_returns_the_first_book
  #   assert Book.first.title.include? "Philosopher"
  # end

  # def test_normal_enumerable_methods_work
  #   assert_equal 7, Book.count { |b| b.author == "Joanne K. Rowling" }
  # end

  # def test_work_on_real_objects
  #   book = Book.first
  #   book.author = "William Shakespeare"
  #   assert_equal Book.first.author, "William Shakespeare"
  # end
end
