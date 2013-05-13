require "test/unit"
require "maglev_record"
require "example_model"

class ActiveModelLikeInterfaceTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def model
    b = RootedBook.example
    # need to trigger method_missing, because respond_to? does not call method_missing
    b.valid?
    b
  end
end
