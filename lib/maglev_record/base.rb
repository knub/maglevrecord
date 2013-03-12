module MaglevRecord
  module Base
    extend MaglevSupport::Concern
    include MaglevRecord::Integration
    include MaglevRecord::Persistence
  end
end
