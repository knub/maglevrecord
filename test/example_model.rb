require "maglev_record"

class Book
  include MaglevRecord::RootedBase

  attr_accessor :author, :title, :comments

  validates :author, :presence => true
  validates :title,  :presence => true,
                     :length => { :minimum => 5 }

  def to_s
    title
  end

  def self.dummy
    Book.new(:title => "Harry Potter and the Chamber of Secrets", :author => "Joanne K. Rowling")
  end

end


class MigrationBook
  include MaglevRecord::Base
  attr_accessor :author

  def self.setupForMigration
    clear()
    m =  10
    (1..m).each{|i|
      new(:title => "MigrationBook #{i}").save()
    }
    assert self.size == m, "#{self.size} == #{m}"
    class_eval{
      dirty_attr_accessor :title, :comments
    }
  end

end
