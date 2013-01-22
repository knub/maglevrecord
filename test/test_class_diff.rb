require 'rubygems'
require 'test/unit'
require 'test/auto_migration'

 class ClassDiffTest < Test::Unit::TestCase

 	def setup
 		@x1 = Class.new {
 			@number = 1
 			@@variable = 'a'
 			def method1
 			end

 			def self.name
 				"TestClass"
 			end

 			def self.themethod
 			end}
 		@x2 = Class.new {
 			@number = 1
 			@@variable = 'a'
 			def method1
 			end

 			def self.themethod
 			end}
 	end

 	def teardown
 	end

 	def test_the_class_is_class
 		assert_equal Class, @x1.class
 	end

 	def test_methods_of_the_classes_are_the_same
 		assert_equal @x1.methods, @x2.methods
 		assert_equal @x1.instance_variables, @x2.instance_variables
 		assert_equal @x1.class_variables, @x2.class_variables
 		assert_equal @x1.instance_methods, @x2.instance_methods
 	end

 	def test_setup_method
	 	t = @x1.new
		assert_equal @x1.instance_variables, ["@number"]
		assert_equal ["@@variable"], t.class.class_variables
		assert @x1.methods.include? "themethod"
		assert @x1.instance_methods.include? "method1"
 	end

 	def test_class_methods_differ
 		class <<@x1
 			remove_method :themethod
 		end
 		assert_not_equal @x1.methods, @x2.methods
 		assert_equal @x2.methods - @x1.methods, ["themethod"]
 	end

 	def test_variables_differ
 		@x1.remove_instance_variable :@number
 		assert_not_equal @x1.instance_variables, @x2.instance_variables
 		assert_equal @x2.instance_variables - @x1.instance_variables, ["@number"]
 	end

 	def test_class_variables_differ
 		puts "PRINT!!!!!!!!!!!!!!!!!!!!!"
 		puts @x1.class_variables.sort.inspect
		@x1.remove_class_variable :@@variable
 		assert_not_equal @x1.class_variables, @x2.class_variables
 		assert_equal @x2.class_variables - @x1.class_variables, ["@@variable"]
 	end

 	def test_instance_methods_differ
 		@x1.remove_method :method1
 		assert_not_equal @x1.instance_methods, @x2.instance_methods
 		assert_equal @x2.instance_methods - @x1.instance_methods, ["method1"]
 	end
 end

 class DetectDifferenceTest < Test::Unit::TestCase

 	def setup
 		@x1 = Class.new {
 			@number = 1
 			@@variable = 'a'
 			def method1
 			end

 			def self.name
 				"TestClass"
 			end

 			def self.themethod
 			end}
 		@x2 = Class.new {
 			@number = 1
 			@@variable = 'a'
 			def method1
 			end

 			def self.themethod
 			end}
 	end

 	def teardown
 	end

 	def test_detects_difference
 		@x1.remove_method :method1
 		assert_equal AutoMigration.compare(@x2, @x1), {:remove_instance_method=>["method1"], :remove_class_method=>[], :remove_instance_variable=>[]}
 	end
 end
