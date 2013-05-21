require 'more_asserts'
require 'tempfile'
require 'migration/base_lectures'

LECTURE_TEMPFILE = Tempfile.new(['lectures', '.rb'])
LECTURES_STRING = <<LectureString

#puts "Loading Lectures except these \#{LECTURES_NOT_TO_LOAD}"

unless LECTURES_NOT_TO_LOAD.include? 'Lecture0'
  class Lecture0
    # empty Lecture
    include MaglevRecord::RootedBase
    def x;end
  end
end

unless LECTURES_NOT_TO_LOAD.include? 'Lecture'
  class Lecture < BaseLecture1
    def x;end
  end
end

unless LECTURES_NOT_TO_LOAD.include? 'Lecture2'
  class Lecture2 < BaseLecture2
    def x;end
  end
end

unless LECTURES_NOT_TO_LOAD.include? 'Lecture3'
  class Lecture3 < Lecture
    def x;end
  end
end

unless LECTURES_NOT_TO_LOAD.include? 'Lecture4'
  class Lecture4 < Lecture
    def x;end
  end
end

module Models
  module M1
    class Lecture < BaseLecture2
      def x;end
    end
  end
  module M2
  end
  module M3
  end
end

"Lecture Lecture0 Lecture2 Lecture3 Lecture4".split.each do |const|
   Object.const_get(const).maglev_record_persistable if Object.const_defined? const
end

LectureString

LECTURES_NOT_TO_LOAD = []  # a list of lectures that are removed from the file

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
    LECTURES_NOT_TO_LOAD.delete_if{|i| true}
    Kernel.load LECTURE_TEMPFILE.path
  end

  as_instance_method :setup_migration_operations, :teardown_migration_operations
  as_instance_method :redefine_migration_classes

end
