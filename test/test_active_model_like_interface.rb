require "test/unit"
require "maglev_record"
puts "Before requiring example_model."
require "example_model"

class ActiveModelLikeInterfaceTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  def model
    Book.dummy
  end
end
