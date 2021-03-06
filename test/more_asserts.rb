require 'test/unit'
require 'maglev_record'


class Test::Unit::TestCase

  def assert_not(bool, message = nil)
    assert_equal false, bool, message
  end

  def assert_include?(array, element)
    assert array.include?(element), "#{array}\n should include \n#{element}"
  end

  def assert_not_include?(array, element)
    assert_not array.include?(element), "#{array}\n should not include \n#{element}"
  end


  # run once before all tests
  def self.startup
  end

  # run once after all tests
  def self.shutdown
  end

  class << self
    alias :old_suite :suite

    def suite
      mysuite = old_suite
      #puts "suite: #{mysuite}"
      def mysuite.run(*args)
        @tests.first.class.startup() unless @tests.empty?
        super
        @tests.first.class.shutdown() unless @tests.empty?
      end
      mysuite
    end
  end

  #
  # make the class methods available as instance methods
  #
  def self.as_instance_method(*names)
    names.each{ |name|
      name = name.to_s
      self.class_eval "def #{name}(*args); self.class.#{name}(*args);end"
    }
  end

end

#  class MyTest < Test::Unit::TestCase
#    def self.startup
#      puts 'runs only once at start2'
#    end
#    def self.shutdown
#      puts 'runs only once at end2'
#    end
#  end

