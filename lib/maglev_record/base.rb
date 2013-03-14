module MaglevRecord
  module Base
    extend MaglevSupport::Concern
    include MaglevRecord::Integration
    include MaglevRecord::Persistence
    include MaglevRecord::ReadWrite
    extend ActiveModel::Naming
  end
end
