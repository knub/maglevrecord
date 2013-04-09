require "maglev_record"


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

def self.setup_migration_operations
  remove_constant :Lecture
  remove_constant :Lecture2
  remove_constant :Lecture3
  remove_constant :Lecture4
  module_eval "
    class Lecture < BaseLecture1
    end

    class Lecture2 < BaseLecture2
    end

    class Lecture3 < Lecture
    end

    class Lecture4 < Lecture
    end
  "
end


