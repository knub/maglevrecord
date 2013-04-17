require 'maglev_record/migration'
#require 'rails'
#


module MaglevRecord
  class Railtie < Rails::Railtie
    railtie_name :maglev_record
    puts "loaded railtie!"
    rake_tasks do
      puts "loaded rake tasks"
      load "tasks/database.rake"
    end
  end
end

