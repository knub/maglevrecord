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
  validates :author, :presence => true,
                     :length => { :minimum => 4 }
end

class UnrootedBook < Book
  include MaglevRecord::Base
end

MaglevRecord.maglev_persistable(true)
Book.maglev_persistable(true)
RootedBook.maglev_persistable(true)
ActiveSupport.maglev_nil_references
ActiveSupport::Concern.maglev_nil_references
ActiveSupport::Callbacks.maglev_nil_references
ActiveSupport::Callbacks::Callback.maglev_nil_references
ActiveSupport::Callbacks::CallbackChain.maglev_nil_references
ActiveModel.maglev_nil_references
ActiveModel::Errors.maglev_nil_references
ActiveModel::Validations.maglev_nil_references
ActiveModel::Validations::ClassMethods.maglev_nil_references
ActiveModel::Validations::HelperMethods.maglev_nil_references
ActiveModel::Translation.maglev_nil_references
ActiveModel::Validations::LengthValidator.maglev_nil_references
ActiveModel::Validations::PresenceValidator.maglev_nil_references

ref_finder = ModuleReferenceFinder.new
referenced_modules = ref_finder.find_referenced_modules_for(MaglevRecord, MaglevSupport)
referenced_modules.each do |mod|
  mod.maglev_persistable(true)
end
