####
#
#   Test Cases for removing
#
#   - instance variables
#
#   - attributes
#
#   - classes
#
#   - instance methods
#
#   - class methods
#

require "migration/operation_setup"
require "more_asserts"
require 'time'

################## remove instance_variable

class TestMigrationRemoveInstanceVariable < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture.fill_with_examples
  end

  def migration1
    MaglevRecord::Migration.new(Time.now, "remove instance variable") do
      def up
        Lecture.delete_instance_variable(:@lecturer)
      end
    end
  end

  def test_instance_variable_is_removed
    migration1.do
    assert_not Lecture.first.instance_variable_defined?(:@lecturer)
    assert_nil Lecture.first.instance_variable_get(:@lecturer)
  end

  def migration2
    MaglevRecord::Migration.new(Time.now, "delete instance variable") do
      def up
        @lecturers = []
        Lecture.delete_instance_variable(:@lecturer) {
          |lecturer|
          # you could do some garbage collection help here
          # inthis case we just save the contents of the variable
          # to prove the block is called with the right argument
          @lecturers << lecturer
        }
      end
      def lecturers
        @lecturers
      end
    end
  end

  def test_instance_variable_is_removed_with_block
    migration2.do
    assert_not Lecture.first.instance_variable_defined?(:@lecturer)
    assert_nil Lecture.first.instance_variable_get(:@lecturer)
  end

  def test_block_is_called_with_deleted_content
    lecturers = Lecture.collect{ |l| l.instance_variable_get(:@lecturer)}
    migration = migration2
    migration.do
    assert_equal lecturers.sort, migration.lecturers.sort
  end

  def test_first_lecture_has_lecturer
    assert Lecture.first.instance_variable_defined?(:@lecturer)
    assert_not_nil Lecture.first.instance_variable_get(:@lecturer)
  end

end

################## remove attribute

class TestMigrationRemoveAttribute < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture2.fill_with_examples
  end

  def migration1
    MaglevRecord::Migration.new(Time.now, "remove attribute") do
      def up
        Lecture2.delete_attribute(:lecturer)
      end
    end
  end

  def test_attribute_is_removed
    migration1.do
    assert_nil Lecture2.first.lecturer
  end

  def migration2
    MaglevRecord::Migration.new(Time.now, "remove attribute lecturer") do
      def up
        @lecturers = []
        Lecture2.delete_attribute(:lecturer) {
          |lecturer|
          # you could do some garbage collection help here
          # inthis case we just save the contents of the variable
          # to prodo some garbage collection help
          @lecturers << lecturer
        }
      end
      def lecturers
        @lecturers
      end
    end
  end

  def test_attribute_is_removed_with_block
    migration2.do
    assert_nil Lecture2.first.lecturer
  end

  def test_block_is_called_with_deleted_content
    lecturers = Lecture2.collect{ |l| l.lecturer }
    migration = migration2
    migration.do
    assert_equal lecturers.sort, migration.lecturers.sort
  end

  def test_first_lecture_has_lecturer
    assert_not_nil Lecture2.first.lecturer
  end

end

################## remove classes

class TestMigrationRemoveClass < Test::Unit::TestCase

  def setup
    setup_migration_operations
  end

  def migration1
    MaglevRecord::Migration.new(Time.now, "remove class Lecture") do
      def up
        delete_class(Lecture)
      end
    end
  end

  def test_class_is_not_present_after_deletion
    migration1.do
    assert_raise(NameError) {
      Lecture
    }
  end

  def test_objects_are_not_referenced_by_object_pool_after_deletion
    object_pool = Lecture.object_pool
    migration1.do
    assert object_pool.empty?
  end

  def migration2
    MaglevRecord::Migration.new(Time.now, "remove class Lecture") do
      def up
        @lectures = []
        delete_class(Lecture) {
          |lecture|
          @lectures << lecture
        }
      end
      def lectures
        @lectures
      end
    end
  end

  def test_block_yields_all_instances_of_lecture
    migration = migration2
    instances = Lecture.all
    migration.do
    assert_equal instances.sort, migration.lectures.sort
  end

  def test_object_pool_is_existent_before_delete
    pool_dict = Maglev::PERSISTENT_ROOT[MaglevRecord::PERSISTENT_ROOT_KEY]
    object_pool = Lecture.object_pool
    assert pool_dict.values.any?{|v| v.equal? object_pool}
    # this test belongs to test_object_pool_removed_from_pool_dict
  end

  def test_object_pool_removed_from_pool_dict
    pool_dict = Maglev::PERSISTENT_ROOT[MaglevRecord::PERSISTENT_ROOT_KEY]
    object_pool = Lecture.object_pool
    migration1.do
    assert_not pool_dict.values.any?{|v| v.equal? object_pool}
  end

  def migration_remove_nested_class
    MaglevRecord::Migration.new(Time.now, "remove class Lecture") do
      def up
        delete_class(Models::M1::Lecture)
      end
    end
  end

  def test_remove_nested_class
    Models::M1::Lecture
    migration_remove_nested_class.do
    assert_raise(NameError){
      Models::M1::Lecture
    }
  end
end

################## remove instance methods

class TestMigrationRemoveInstanceMethod < Test::Unit::TestCase

  def setup
    setup_migration_operations
    Lecture.define_method :instance_method_to_remove do 2 end
    Lecture.fill_with_examples
    Lecture3.fill_with_examples
  end

  def test_Lecture_has_instance_method
    assert_equal 2, Lecture.first.instance_method_to_remove
    assert_equal 2, Lecture3.first.instance_method_to_remove
  end

  def teardown
    super
    teardown_migration_operations
  end

  def test_migration_removes_instance_method
    MaglevRecord::Migration.new(Time.now, "remove instance method") do
      def up
        Lecture.remove_instance_method :instance_method_to_remove
      end
    end.do
    assert_raises(NoMethodError){
      Lecture.first.instance_method_to_remove
    }
    assert_raises(NoMethodError){
      Lecture3.first.instance_method_to_remove
    }
  end

  def test_migration_removes_nonexistent_instance_method
    MaglevRecord::Migration.new(Time.now, "remove instance method") do
      def up
        Lecture.remove_instance_method :instance_method_to_remove2
      end
    end.do
    assert_equal 2, Lecture.first.instance_method_to_remove
  end

  def test_remove_instance_method_of_nonexistent_class
    MaglevRecord::Migration.new(Time.now, "remove instance method") do
      def up
        AbsentLectureClass.remove_instance_method :method_not_here
      end
    end.do
    assert_equal 2, Lecture.first.instance_method_to_remove
  end

  def test_remove_instance_method_of_subclass_does_not_influence_superclass
    MaglevRecord::Migration.new(Time.now, "remove instance method") do
      def up
        Lecture3.remove_instance_method :instance_method_to_remove
      end
    end.do    
    assert_equal 2, Lecture.first.instance_method_to_remove
    assert_equal 2, Lecture3.first.instance_method_to_remove
  end
end

################## remove class methods

class TestMigrationRemoveClassMethod < Test::Unit::TestCase

  def setup
    setup_migration_operations
    def Lecture.class_method_to_remove;1;end
  end

  def teardown
    super
    teardown_migration_operations
  end

  def test_Lecture_has_class_method
    assert_equal 1, Lecture.class_method_to_remove
  end

  def test_migration_removes_class_method
    MaglevRecord::Migration.new(Time.now, "remove class method") do
      def up
        Lecture.remove_class_method :class_method_to_remove
      end
    end.do
    assert_raises(NoMethodError){
      Lecture.class_method_to_remove
    }
  end

  def test_migration_removes_nonexistent_class_method
    MaglevRecord::Migration.new(Time.now, "remove class method") do
      def up
        Lecture.remove_class_method :class_method_to_remove2
      end
    end.do
    assert_equal 1, Lecture.class_method_to_remove
  end

  def test_remove_instance_method_of_nonexistent_class
    MaglevRecord::Migration.new(Time.now, "remove class method") do
      def up
        AbsentLectureClass.remove_class_method :method_not_here
      end
    end.do
    assert_equal 1, Lecture.class_method_to_remove
  end

  def test_remove_class_method_of_subclass_does_not_influence_superclass
    MaglevRecord::Migration.new(Time.now, "remove class method") do
      def up
        Lecture3.remove_instance_method :class_method_to_remove
      end
    end.do    
    assert_equal 1, Lecture.class_method_to_remove
  end
end
