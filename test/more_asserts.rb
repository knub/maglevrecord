require 'test/unit'

class Test::Unit::TestCase

  def assert_not(bool, message = nil)
    assert_equal false, bool, message
  end

  def assert_include?(array, element)
    assert array.include?(element), "#{array}\n should include \n#{element}"
  end

end



