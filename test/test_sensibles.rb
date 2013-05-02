require "more_asserts"
require "maglev_record"

class User
  include MaglevRecord::RootedBase
  attr_accessor :password_digest

  has_secure_password
  # TODO: No validations so far
  # validates_presence_of :password, :on => :create
end

class SensibleTest #< Test::Unit::TestCase

  def pass
    "some_pass"
  end

  def example_user
    attr_hash = {
      :password => pass,
      :password_confirmation => pass,
    }
    User.new(attr_hash)
  end

  def test_sensible_deletion
    user = example_user

    assert_equal user.password, pass
    assert_equal user.password_confirmation, pass

    user.clear_sensibles

    assert_equal user.password, nil
    assert_equal user.password_confirmation, nil
  end
end