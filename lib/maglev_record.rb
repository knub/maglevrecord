puts "Loading maglev_record..."

# require "maglev_record/settings"
# require "maglev_record/rooted_base"
Maglev.persistent do
  require "maglev_record/maglev_record"
  require "maglev_record/base"
  require "maglev_record/errors"
end
# require "maglev_record/naming"
# require "maglev_record/integration"
# require "maglev_record/logger"
# require "maglev_record/migration"
# require "maglev_record/object_reference"

# MaglevRecord.make_modules_persistent
# MaglevRecord::Base.load_model_files

