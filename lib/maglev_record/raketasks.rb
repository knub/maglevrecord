require 'maglev_record/migration'
require 'rails'

class Railtie < Rails::Railtie
  railtie_name :maglev_record
  rake_tasks do
    load "tasks/database.rake"
  end
end
