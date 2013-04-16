
require "active_model/naming"
require "active_model"

require "active_support/core_ext/class/attribute"
require "active_support/dependencies"
require "maglev_record/maglev_support/active_support_patch"

require "bundler/setup"
require "tsort"

unless defined?(Rake)


require "maglev_record/maglev_support/concern"
require "maglev_record/maglev_record"

require "maglev_record/enumerable"
require "maglev_record/errors"
require "maglev_record/integration"
require "maglev_record/persistence"
require "maglev_record/read_write"
require "maglev_record/rooted_persistence"

require "maglev_record/migration"

require "maglev_record/base"
require "maglev_record/rooted_base"

require "maglev_record/tools"

# require "maglev_record/object_reference"
# MaglevRecord.make_modules_persistent
# MaglevRecord::Base.load_model_files

#require 'tasks/maglev_record.rb' if defined? Rake
end
module MaglevRecord
  require 'maglev_record/railtie' if defined?(Rake) or defined?(Rails)
end 
