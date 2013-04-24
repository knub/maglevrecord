module MaglevRecord
  module Base
    extend MaglevSupport::Concern
    extend ActiveModel::Naming
    include MaglevRecord::Integration
    include MaglevRecord::Persistence
    include MaglevRecord::ReadWrite
    include MaglevRecord::Enumerable
    include MaglevRecord::MigrationOperations
    include ActiveModel::Conversion
    include MaglevSupport::SecurePassword
  end
end
