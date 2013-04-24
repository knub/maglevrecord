require 'maglev_record/migration'
require 'rails'


#
# This is for rails
#
module MaglevRecord
  class Railtie < Rails::Railtie
    railtie_name :maglev_record
    rake_tasks do
      load "tasks/database.rake"
    end
  end
end

