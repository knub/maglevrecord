require 'more_asserts'
require 'tempfile'
require 'migration/base_lectures'


LECTURE_TEMPFILE = Tempfile.new(['lectures', '.rb'])
LECTURES_STRING = <<LectureString

class Lecture0
  # empty Lecture
  include MaglevRecord::RootedBase
  def _;end
end

class Lecture < BaseLecture1
  def _;end
end

class Lecture2 < BaseLecture2
  def _;end
end

class Lecture3 < Lecture
  def _;end
end

class Lecture4 < Lecture
  def _;end
end

module Models
  module M1
    class Lecture < BaseLecture2
      def _;end
    end
  end
  module M2
  end
  module M3
  end
end

[Lecture, Lecture2, Lecture3, Lecture4, Lecture0].each do |const|
  const.maglev_record_persistable
end

LectureString

class Test::Unit::TestCase

  def self.teardown_migration_operations
    [:Lecture, :Lecture2, :Lecture3, :Lecture4, :Lecture0].each{ |const|
      if Object.const_defined? const
        Object.const_get(const).clear
        Maglev.persistent do
          Object.remove_const const
        end
      end
    }
    LECTURE_TEMPFILE.rewind
    LECTURE_TEMPFILE.write " " * LECTURE_TEMPFILE.size
  end

  def self.setup_migration_operations
    self.teardown_migration_operations
    self.redefine_migration_classes
  end

  def self.redefine_migration_classes
    LECTURE_TEMPFILE.rewind
    LECTURE_TEMPFILE.write LECTURES_STRING
    Kernel.load LECTURE_TEMPFILE.path
  end

  as_instance_method :setup_migration_operations, :teardown_migration_operations
  as_instance_method :redefine_migration_classes

end
