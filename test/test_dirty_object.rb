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

  def new_model
    Book.dummy
  end

  def test_no_save_or_reset_throws_error
    m = new_model
    m.author = "Shakespeare"
    assert_raise Exception do
      Maglev.commit_transaction
    end
  end

  def test_reset_throws_no_error
    m = new_model
    m.author = "Shakespeare"
    m.reset
    assert_nothing_raised Exception do
      Maglev.commit_transaction
    end
    assert_equal m.author, "Joanne K. Rowling"
  end

  def test_save_throws_no_error
    m = new_model
    m.author = "Shakespeare"
    m.save
    assert_nothing_raised Exception do
      Maglev.commit_transaction
    end
    assert_equal m.author, "Shakespeare"
  end
end
