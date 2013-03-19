require "test/unit"
require "maglev_record"
require "example_model"

class ActiveModelLikeInterfaceTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def model
    RootedBook.example
  end
end
