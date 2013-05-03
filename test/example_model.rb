class Book
  include MaglevRecord::ReadWrite
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

class RootedBook
  include ActiveModel::Validations
  validates :author, :presence => true,
                     :length => { :minimum => 4 }
end
