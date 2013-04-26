
require "active_model"
require "active_support"
require "active_support/core_ext/class/attribute"

require "maglev_record/maglev_support/maglev_support"
require "bundler/setup"

require "maglev_record/maglev_support/concern"
require "maglev_record/tools"
require "maglev_record/maglev_record"

require "maglev_record/enumerable"
require "maglev_record/errors"
require "maglev_record/integration"
require "maglev_record/persistence"
require "maglev_record/read_write"
require "maglev_record/rooted_persistence"

require "maglev_record/migration"

require "maglev_record/base"
require "maglev_record/rooted_base"

# require "maglev_record/object_reference"

MaglevRecord.maglev_persistable(true)

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

ref_finder = MaglevSupport::ModuleReferenceFinder.new
referenced_modules = ref_finder.find_referenced_modules_for(MaglevRecord, MaglevSupport, Set)
puts referenced_modules
referenced_modules.each do |mod|
  mod.maglev_persistable(true)
end

Maglev.commit_transaction