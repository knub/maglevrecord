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
  # validates :author, :presence => true,
                     # :length => { :minimum => 4 }
end

class UnrootedBook < Book
  include MaglevRecord::Base
end

MaglevRecord.maglev_persistable(true)
Book.maglev_persistable(true)
RootedBook.maglev_persistable(true)

ref_finder = ModuleReferenceFinder.new
referenced_modules = ref_finder.find_referenced_modules_for(MaglevRecord, MaglevSupport)
#puts referenced_modules.inspect
referenced_modules.each do |mod|
  mod.maglev_persistable(true)
end
