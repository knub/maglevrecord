require "maglev_record"
require "more_asserts"
require 'time'

################## instance variables

class Lecture
  include MaglevRecord::RootedBase

  def initialize(lecturer, users)
    @lecturer = lecturer
    @users = users
  end

  def self.fill_with_examples
    self.clear
    self.new("Hans Ullrich", ["Peter Garstig", "Elfride Bricht", "Sergey Faehrlich"])
  end

end

class TestMigrationRenameInstanceVariable < Test::Unit::TestCase

  def setup
    Lecture.fill_with_examples
  end

  def m1
    Migration.new(Time.now, "rename instance variable") do
      def up
        Lecture.rename_instance_variable(:@lecturer , :@lecturers) {
          |lecturer|
          [lecturer]
        }
      end
    end
  end

  def test_rename_inst_var_with_block
    lecturer = Lecture.first.instance_variable_get(:@lecturer)
    m1.up
    assert_equal Lecture.first.instance_variable_get(:@lecturers), [lecturer]
  end

  def test_lecturer_exists
    assert_not_nil Lecture.first.instance_variable_get(:@lecturer)
  end

  def test_raise_error_if_no_down_given
    m1.up
    assert_raise(MaglevRecord::IrreversibleMigration) {
      m1.down
    }
  end

  def m2
    Migration.new(Time.now, "rename instance variable") do
      def up
        Lecture.rename_instance_variable(:@users , :@attendees)
      end
    end
  end

  def test_rename_inst_var
    users = Lecture.first.instance_variable_get(:@users)
    m2.up
    assert_equal Lecture.first.instance_variable_get(:@attendees), users
  end

  def test_users_exists
    assert_not_nil Lecture.first.instance_variable_get(:@users)
  end
end

################## attributes

class Lecture2
  include MaglevRecord::RootedBase

  attr_accessor :lecturer, :users

  def self.fill_with_examples
    self.clear
    lecture = self.new()
    lecture.lecturer = "Hans Ullrich"
    lecture.users = ["Peter Garstig", "Elfride Bricht", "Sergey Faehrlich"]
  end

end

class TestMigrationRenameAttributes < Test::Unit::TestCase

  def setup
    Lecture2.fill_with_examples
  end

  def m3
    Migration.new(Time.now, "rename attribute") do
      def up
        Lecture2.rename_attribute(:lecturer , :lecturers) {
          |lecturer|
          [lecturer]
        }
      end
    end
  end

  def test_rename_attribute_with_block
    lecturer = Lecture2.first.lecturer
    m3.up
    assert_equal Lecture2.first.lecturers, [lecturer]
  end

  def test_attr_lecturer_exists
    assert_not_nil Lecture2.first.lecturer
  end

  def m4
    Migration.new(Time.now, "rename attribute") do
      def up
        Lecture2.rename_instance_variable(:users , :attendees)
      end
    end
  end

  def test_rename_attribute
    users = Lecture2.first.users
    m4.up
    assert_equal Lecture2.first.attendees, users
  end

  def test_attr_users_exists
    assert_not_nil Lecture2.first.users
    assert_not_equal Lecture2.first.users, []
  end

end
