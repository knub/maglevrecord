require 'maglev_record/migration'
#require 'rails'
#


module MaglevRecord
  class Railtie < Rails::Railtie
    railtie_name :maglev_record
    rake_tasks do
      load "tasks/database.rake"
    end
  end
end

