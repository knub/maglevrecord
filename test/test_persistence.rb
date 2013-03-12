require "more_asserts"
require "maglev_record"
require "example_model"

class MaglevSimplePersistanceTest < Test::Unit::TestCase

  def example_book
    UnrootedBook.new(:author => "Author", :title => "Title")
  end

  def setup
  end

  def test_new_creates_new_object
    b = example_book
    assert_not_nil b
    assert_equal b.author, "Author"
    assert_equal b.title, "Title"
  end

  def test_new_object_is_maglev_persistable
    assert example_book.class.maglev_persistable?
  end

  def test_new_object_is_not_persisted
    b = example_book
    assert b.new_record?
    assert_not b.persisted?
  end

  def test_persisted_object_is_persisted
    b = example_book
    Maglev::PERSISTENT_ROOT[:test] = b
    assert b.new_record?
    assert_not b.persisted?
    MaglevRecord.save
    assert b.persisted?
    assert_not b.new_record?
  end

  def test_create_on_unrooted_model_should_raise_error
    assert_raise MaglevRecord::InvalidOperationError do
      UnrootedBook.create
    end
  end

end