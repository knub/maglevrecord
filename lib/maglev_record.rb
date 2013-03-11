puts "loading maglev_record..."

require "maglev_record/settings"
require "maglev_record/enumerable"
require "maglev_record/rooted_base"
require "maglev_record/base"
require "maglev_record/naming"
# require "maglev_record/logger"
require "maglev_record/persistence"
require "maglev_record/migration"
require "maglev_record/transaction_request_wrapper"
require "maglev_record/object_reference"

[
  MaglevRecord,
  MaglevRecord::Base,
  MaglevRecord::Base::ClassMethods,
  MaglevRecord::RootedBase,
  MaglevRecord::RootedPersistence,
  MaglevRecord::RootedPersistence::ClassMethods,
  MaglevRecord::Enumerable,
  MaglevRecord::Enumerable::ClassMethods,
  MaglevRecord::ReadWrite,
  MaglevRecord::ReadWrite::ClassMethods,
  MaglevRecord::Naming,
  MaglevRecord::Name,

].each { |m|
  m.maglev_persistable
}

puts "Loading base..."

MaglevRecord::Base.all.each do |model|
  name = ActiveSupport::Dependencies.qualified_name_for(Object, model).underscore
  file = ActiveSupport::Dependencies.search_for_file(name)

  if (file)
    ActiveSupport::Dependencies.require_or_load file
  else
    puts "Warning: cannot find model file for #{name}"
  end
end

