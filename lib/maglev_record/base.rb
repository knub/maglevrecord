
$LOAD_PATH << "./lib"
require "maglev_record/maglev_support/concern"
require "maglev_record/persistence"
require "maglev_record/integration"

module MaglevRecord
  module Base
    extend MaglevSupport::Concern
    include MaglevRecord::Integration
    include MaglevRecord::Persistence
  end
end
