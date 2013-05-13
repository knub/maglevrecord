module MaglevRecord
  module Base
    extend MaglevSupport::Concern
    include MaglevRecord::Integration
    include MaglevRecord::Persistence
    include MaglevRecord::ReadWrite
    include MaglevRecord::MigrationOperations
    redo_include ActiveModel::Conversion
    redo_include MaglevRecord::Validations
    include MaglevRecord::Sensible
    include ActiveModel::Conversion
    include MaglevRecord::SecurePassword
    include MaglevRecord::Snapshotable
  end
end
