module MaglevRecord
  module Base
    extend MaglevSupport::Concern
    include MaglevRecord::Integration
    include MaglevRecord::Persistence
    include MaglevRecord::ReadWrite
    include MaglevRecord::Enumerable
    include MaglevRecord::MigrationOperations
    redo_include ActiveModel::Conversion
  end
end
