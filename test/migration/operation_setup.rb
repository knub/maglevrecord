require 'more_asserts'

class BaseLecture1
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

class BaseLecture2
  include MaglevRecord::RootedBase

  attr_accessor :lecturer, :users

  def self.fill_with_examples
    self.clear
    lecture = self.new()
    lecture.lecturer = "Hans Ullrich"
    lecture.users = ["Peter Garstig", "Elfride Bricht", "Sergey Faehrlich"]
  end
end

class Test::Unit::TestCase

  def self.teardown_migration_operations
    [:Lecture, :Lecture2, :Lecture3, :Lecture4].each{ |const|
      if Object.const_defined? const
        Object.const_get(const).clear
        Maglev.persistent do
          Object.remove_const const
        end
      end
    }
  end

  def self.setup_migration_operations
    self.teardown_migration_operations
    self.redefine_migration_classes
  end

  def self.redefine_migration_classes
    Object.module_eval "
      class Lecture < BaseLecture1
      end

      class Lecture2 < BaseLecture2
      end

      class Lecture3 < Lecture
      end

      class Lecture4 < Lecture
      end

      [Lecture, Lecture2, Lecture3, Lecture4].each do |const|
        const.maglev_persistable(true)
      end
    "
  end

  def setup_migration_operations
    self.class.setup_migration_operations
  end

  def teardown_migration_operations
    self.class.teardown_migration_operations
  end

  def redefine_migration_classes
    self.class.redefine_migration_classes
  end

end
