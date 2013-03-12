require "more_asserts"
require "maglev_record"
require "example_model"

class AccessorTest < Test::Unit::TestCase

  def rooted_example_book
    RootedBook.example
  end

  def unrooted_example_book
    UnrootedBook.example
  end

  def test_accessors_working
    [rooted_example_book, unrooted_example_book].each do |b|
      assert_equal b.author, "Author"
      assert_equal b.title, "Title"
    end
  end

  def test_accessors_are_not_instance_variables
    [rooted_example_book, unrooted_example_book].each do |b|
      # In ruby 1.9 these are Symbols!
      assert_not b.instance_variables.include? "@author"
      assert_not b.instance_variables.include? "@title"
    end
  end

  def test_accessors_are_stored_in_a_hash
    [rooted_example_book, unrooted_example_book].each do |b|
      assert b.attributes.is_a? Hash
      assert b.attributes.has_key? :author
      assert b.attributes.has_key? :title
    end
  end

  def test_updating_attributes
    [rooted_example_book, unrooted_example_book].each do |b|
      b.update_attributes(:title => "New Title", :author => 2)
      assert_equal b.title, "New Title"
      assert_equal b.author, 2
    end
  end

end