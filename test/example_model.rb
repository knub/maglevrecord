require "maglev_record"

class Book
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
end

class UnrootedBook < Book
  include MaglevRecord::Base
end
