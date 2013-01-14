# Maglev.persistent do
#   Object.remove_const(:NotSavedOnReset)
# end
# Maglev.commit_transaction

# Maglev.transient do
#   class ModelNotSavedOrReset
#   end
# end

# Maglev::PERSISTENT_ROOT['tmp'] = NotSavedOnReset.new
# Maglev.commit_transaction

require 'rubygems'
require 'test/unit'

class DirtyObjectTest < Test::Unit::TestCase

  def setup
    Maglev.abort_transaction
    @book = Book.dummy
    @book.save
    Maglev.commit_transaction
  end

  def teardown
    Maglev.abort_transaction
    Book.clear
    Maglev.commit_transaction
  end

  def test_no_save_or_reset_throws_error
    @book.author = "Shakespeare"
    exception = false
    begin
      Maglev.commit_transaction
    rescue Exception
      exception = true
    end

    assert exception
  end

  def test_reset_throws_no_error
    @book.author = "Shakespeare"
    @book.reset!
    assert_nothing_raised Exception do
      Maglev.commit_transaction
    end
    assert_equal "Joanne K. Rowling", @book.author
  end

  def test_save_throws_no_error
    @book.author = "Shakespeare"
    @book.save
    assert_nothing_raised Exception do
      Maglev.commit_transaction
    end
    assert_equal @book.author, "Shakespeare"
  end
end
