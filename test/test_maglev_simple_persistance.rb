require "test/unit"
require "maglev_record"
require "example_model"

class MaglevSimplePersistanceTest < Test::Unit::TestCase
  
  def run_with_new_transaction
    Maglev.abort_transaction
    yield
    Maglev.commit_transaction
  end

  def test_model_is_persisted
    run_with_new_transaction do
      book = Book.new(:title => "The Magician's Guild", :author => "Trudi Canavan")
      book.save
    end

    run_with_new_transaction do
      assert_equal Book.find { |b| b.title == "The Magician's Guild"}.author, "Trudi Canavan"
    end
  end

  def test_model_is_deleted
    run_with_new_transaction do
      book = Book.new(:title => "Harry Potter and the Philosopher's stone", :author => "Joanne K. Rowling")
      book.save
    end

    run_with_new_transaction do
      Book.find { |b| b.title == "Harry Potter and the Philosopher's stone"}.delete
    end

    run_with_new_transaction do
      assert_nil Book.find { |b| b.title == "Harry Potter and the Philosopher's stone"}
    end
  end

  def teardown
    run_with_new_transaction do
      Book.clear
    end
  end

end
