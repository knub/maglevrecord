puts "Loading maglev_record..."

# require "maglev_record/settings"
# require "maglev_record/rooted_base"
# Maglev.persistent do
  require "active_model/naming"
  require "maglev_record/maglev_record"
  require "maglev_record/errors"
  require "maglev_record/maglev_support/concern"
  require "maglev_record/integration"
  require "maglev_record/persistence"
  require "maglev_record/rooted_persistence"
  require "maglev_record/read_write"
  require "maglev_record/base"
  require "maglev_record/rooted_base"
# end
# require "maglev_record/integration"
# require "maglev_record/logger"
# require "maglev_record/migration"
# require "maglev_record/object_reference"

# MaglevRecord.make_modules_persistent
# MaglevRecord::Base.load_model_files

