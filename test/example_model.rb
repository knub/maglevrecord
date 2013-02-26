require "maglev_record"

class Book
  include MaglevRecord::RootedBase

  attr_accessor :author, :title, :comments

  validates :author, :presence => true
  validates :title,  :presence => true,
                     :length => { :minimum => 5 }

  def self.dummy
    self.new(:title => "Harry Potter and the Chamber of Secrets", :author => "Joanne K. Rowling")
  end
end


class UnrootedBook
  include MaglevRecord::Base
  attr_accessor :author, :title, :comments
  validates :author, :presence => true
  validates :title,  :presence => true,
                     :length => { :minimum => 5 }
end
