require "active_model"
require "active_support"
require "active_support/core_ext/class/attribute"
require "maglev_record/maglev_support/maglev_support"
require "maglev_record/tools"
require "bundler/setup"
require "maglev_record/maglev_support/concern"
require "set"
require "logger"

if defined? MaglevRecord::VERSION
  if defined? RootedBook
    RootedBook.redo_include_and_extend
  end
  if defined? UnrootedBook
    UnrootedBook.redo_include_and_extend
  end
  MaglevRecord::Migration.redo_include_and_extend
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
  require "maglev_record/validations"
  require "maglev_record/read_write"
  require "maglev_record/rooted_persistence"
  require "maglev_record/migration"
  require "maglev_record/base"
  require "maglev_record/rooted_base"

  module MaglevRecord
    ref_finder = MaglevSupport::SubmoduleFinder.new
    referenced_modules = ref_finder.submodules_for(MaglevRecord, MaglevSupport, Set)
    MAGLEV_RECORD_PROC = Proc.new do |superklass_module|
      referenced_modules.include?(superklass_module)
    end

    Maglev.persistent do
      class ::Module
        def maglev_record_persistable
          self.maglev_persistable(true, &MAGLEV_RECORD_PROC)
        end
      end
    end

    referenced_modules.each do |mod|
      mod.maglev_record_persistable
    end
  end
  Maglev.commit_transaction
end

ActiveModel::Errors.maglev_nil_references
