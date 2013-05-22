module MaglevRecord
  module Base
    extend MaglevSupport::Concern
    include MaglevRecord::Snapshotable
    include MaglevRecord::Integration
    include MaglevRecord::Persistence
    include MaglevRecord::ReadWrite
    include MaglevRecord::MigrationOperations
    redo_include ActiveModel::Conversion
    redo_include MaglevRecord::Validations
    #module ClassMethods
    #  def self.extended(base)
        #base.class_methods_not_to_reset << "_validators"
        #base.class_methods_not_to_reset << "_validators="
        #base.class_methods_not_to_reset << "_validators?"
        #base.class_methods_not_to_reset << "method_missing"
    #  end
    #end
    include MaglevRecord::Sensible
    include ActiveModel::Conversion
    include MaglevRecord::SecurePassword
  end
end
