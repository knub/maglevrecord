require "test/unit"
require "maglev_record"
require "rooted_example_model"

class MaglevSimplePersistanceTest < Test::Unit::TestCase

  def run_with_new_transaction
    Maglev.abort_transaction
    yield
    MaglevRecord.save
  end

  def test_model_is_persisted
    run_with_new_transaction do
      book = RootedBook.new(:title => "The Magician's Guild", :author => "Trudi Canavan")
    end

    run_with_new_transaction do
      assert_equal RootedBook.find { |b| b.title == "The Magician's Guild"}.author, "Trudi Canavan"
    end
  end

  def test_model_is_deleted
    run_with_new_transaction do
      book = RootedBook.new(:title => "Harry Potter and the Philosopher's stone", :author => "Joanne K. Rowling")
    end

    run_with_new_transaction do
      RootedBook.find { |b| b.title == "Harry Potter and the Philosopher's stone"}.delete
    end

    run_with_new_transaction do
      assert_nil RootedBook.find { |b| b.title == "Harry Potter and the Philosopher's stone"}
    end
  end

  def teardown
    run_with_new_transaction do
      RootedBook.clear
    end
  end

end
