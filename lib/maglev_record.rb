require "maglev_record/enumerable"
require "maglev_record/rooted_base"
require "maglev_record/base"
require "maglev_record/logger"
require "maglev_record/persistence"
require "maglev_record/migration"
require "maglev_record/transaction_request_wrapper"
require "maglev_record/object_reference"


[
  ActiveModel,
  ActiveModel::MassAssignmentSecurity,
  ActiveModel::MassAssignmentSecurity::ClassMethods,
  ActiveModel::Validations,
  ActiveModel::Validations::ClassMethods,
  MaglevRecord,
  MaglevRecord::RootedPersistence,
  MaglevRecord::RootedPersistence::ClassMethods,
  MaglevRecord::Enumerable,
  MaglevRecord::Enumerable::ClassMethods,
].each { |m|
  m.maglev_persistable
}