require "maglev_record"

class Book
  include MaglevRecord::Base

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
