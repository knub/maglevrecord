
class Book
  include MaglevRecord::ReadWrite
  include MaglevRecord::Snapshotable

  attr_accessor :author, :title, :comments
  def self.example_params
    { :author => "Author", :title => "Title" }
  end
  def self.example
    self.new(example_params)
  end
end

class RootedBook < Book
  include MaglevRecord::RootedBase
  # TODO: why does rooted book change the ancestors of book?
  validates :author, :presence => true,
                     :length => { :minimum => 4 }
  def book
    puts "I am a RootedBook"
  end
end

class UnrootedBook < Book
  include MaglevRecord::Base
end

Book.maglev_record_persistable
RootedBook.maglev_record_persistable
UnrootedBook.maglev_record_persistable
Maglev.commit_transaction

RootedBook.redo_include_and_extend
