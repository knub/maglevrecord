require 'more_asserts'

class MyTest < Test::Unit::TestCase

    def self.startup
      #puts 'runs only once at start2'
      if @startup_called.nil?
        @startup_called = 1
      else
         @startup_called += 1
      end
      super
    end

    def self.shutdown
      #puts 'runs only once at end2'
      if @shutdown_called.nil?
        @shutdown_called = 1
      else
         @shutdown_called += 1
      end
      super
    end

    def setup
      @setup_called = true
    	#puts 'runs before each test'
    end

    def teardown
      @teardown_called = true
    	#puts 'runs after each test'
    end	

    def test_stuff
    	assert_equal @setup_called, true
      assert_equal @teardown_called, nil
      assert_equal self.class.instance_variable_get( :@shutdown_called ), nil
      assert_equal self.class.instance_variable_get( :@startup_called ), 1
    end

    def test_stuff2
      test_stuff
    end

  class << self
    alias :old_suite123 :suite

    def suite
      raise unless MyTest.instance_variable_get(:@shutdown_called) == nil
      raise unless MyTest.instance_variable_get(:@startup_called) == nil
      ret = old_suite123
      class << ret
        alias :run_old123 :run

        def run(*args, &block)
          raise unless MyTest.instance_variable_get(:@shutdown_called) == nil
          raise unless MyTest.instance_variable_get(:@startup_called) == nil
          ret = run_old123(*args, &block)
          raise unless MyTest.instance_variable_get(:@shutdown_called) == 1
          raise unless MyTest.instance_variable_get(:@startup_called) == 1
          ret
        end
      end
     ret
    end
  end
end
