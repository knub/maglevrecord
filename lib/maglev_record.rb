require "active_model"
require "active_support"
require "active_support/core_ext/class/attribute"

require "maglev_record/maglev_support/maglev_support"


require "maglev_record/tools"
require "bundler/setup"
require "maglev_record/maglev_support/concern"
require "set"
require "logger"

if defined? MaglevRecord
  puts "IT IS DEFINED"
  if defined? RootedBook
    RootedBook.reinclude_store.each do |mod|
      RootedBook.include MaglevSupport.constantize(mod)
    end
    RootedBook.extend MaglevSupport.constantize("ActiveModel::Naming")
    RootedBook.extend ::Enumerable
  end
  if defined? UnrootedBook
    UnrootedBook.reinclude_store.each do |mod|
      UnrootedBook.include MaglevSupport.constantize(mod)
    end
    UnrootedBook.extend MaglevSupport.constantize("ActiveModel::Naming")
  end
  MaglevRecord::Migration.include ::Comparable
else
  puts "IT IS NOT DEFINED"
  # require "maglev_record/tools"
  require "maglev_record/maglev_record"

  require "maglev_record/snapshot"
  require "maglev_record/maglev_support/secure_password"
  require "maglev_record/sensible"
  require "maglev_record/rooted_enumerable"
  require "maglev_record/enumerable"
  require "maglev_record/errors"
  require "maglev_record/integration"
  require "maglev_record/persistence"
  require "maglev_record/read_write"
  require "maglev_record/rooted_persistence"

  require "maglev_record/migration"

  require "maglev_record/base"
  require "maglev_record/rooted_base"
end

module MaglevRecord
  ref_finder = MaglevSupport::SubmoduleFinder.new
  referenced_modules = ref_finder.submodules_for(MaglevRecord, MaglevSupport, Set)
  MAGLEV_RECORD_PROC = Proc.new do |superklass_module|
    # returns true or false whether submodule shall be persisted or not
    answer = referenced_modules.include?(superklass_module)
    answer = superklass_module.to_s.include?("Maglev")
    answer
  end

  class ::Module
    def maglev_record_persistable
      self.maglev_persistable(true, &MAGLEV_RECORD_PROC)
    end
  end

  ActiveModel::Errors.maglev_nil_references
  referenced_modules.each do |mod|
    mod.maglev_record_persistable
  end

  Maglev.commit_transaction
end
