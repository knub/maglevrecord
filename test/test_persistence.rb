require "more_asserts"
require "maglev_record"
require "example_model"

class UnrootedPersistanceTest < Test::Unit::TestCase

  def new_unrooted_example_book
    UnrootedBook.example
  end

  def test_new_creates_new_object
    b = new_unrooted_example_book
    assert_not_nil b
    assert_equal b.author, "Author"
    assert_equal b.title, "Title"
  end

  def test_new_object_is_maglev_persistable
    assert new_unrooted_example_book.class.maglev_persistable?
  end

  def test_new_object_is_not_persisted
    b = new_unrooted_example_book
    assert b.new_record?
    assert_not b.persisted?
  end

  def test_persisted_object_is_persisted
    b = new_unrooted_example_book
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

  def test_clear_on_unrooted_model_should_raise_error
    assert_raise MaglevRecord::InvalidOperationError do
      UnrootedBook.clear
    end
  end

  def test_id_returns_object_id
    b = new_unrooted_example_book
    assert_equal b.id, b.object_id
  end

end

class RootedPersistanceTest < Test::Unit::TestCase

  def new_rooted_example_book
    RootedBook.example
  end

  def setup
    # RootedBook.clear
  end

  def test_new_creates_new_object
    b = new_rooted_example_book
    assert_not_nil b
    assert_equal b.author, "Author"
    assert_equal b.title, "Title"
  end

  def test_new_stores_object_in_persistent_root
    b = new_rooted_example_book
    assert RootedBook.object_pool.has_value? b
  end

  def test_new_object_is_maglev_persistable
    assert new_rooted_example_book.class.maglev_persistable?
  end

  def test_new_object_is_not_persisted
    b = new_rooted_example_book
    assert b.new_record?
    assert_not b.persisted?
  end

  def test_persisted_object_is_persisted
    b = new_rooted_example_book
    Maglev::PERSISTENT_ROOT[:test] = b
    assert b.new_record?
    assert_not b.persisted?
    MaglevRecord.save
    assert b.persisted?
    assert_not b.new_record?
  end

  def test_object_pool_key_is_a_class
    assert_equal RootedBook.object_pool_key, RootedBook
  end

  def test_object_pool_is_a_hash
    assert RootedBook.object_pool.is_a? Hash
  end

  # def test_clear_clears

  #   RootedBook.create(RootedBook.example_params)

  # end

  # def test_create_commits_model
  #   assert_equal RootedBook.size, 0
  #   RootedBook.create(RootedBook.example_params)
  #   MaglevRecord.reset
  #   assert_equal RootedBook.size, 1
  # end

end