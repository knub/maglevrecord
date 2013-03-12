require "maglev_record"

class Book
  attr_accessor :author, :title, :comments
  def self.example
    self.new(:author => "Author", :title => "Title")
  end
end

# class RootedBook < Book
#   include MaglevRecord::RootedBase
# end


class UnrootedBook < Book
  include MaglevRecord::Base
end
