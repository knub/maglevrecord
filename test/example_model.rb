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
  validates :author, :presence => true
end

class UnrootedBook < Book
  include MaglevRecord::Base
end
