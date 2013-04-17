require "maglev_record/migration"
require "time"
require "logger"

puts "!" * 30
puts "maglev_record/tasks/maglev_record.rb loaded"
p Module.nesting

MIGRATION_FOLDER = "migrations"
#Rake::Task['db:migrate'].clea

desc "transform the maglev database"
namespace :maglev do

  desc "migrate all the migrations in the migration folder"
  task :up do
    loader = MaglevRecord::MigrationLoader.new
    loader.load_directory(MIGRATION_FOLDER)
    migrator = MaglevRecord::Migrator.new(loader.migration_list)
    logger = Logger.new(STDOUT)
    migrator.up(logger)
  end

  desc "create a new migration in the migration folder"
  task :new do
    now = Time.now
    filename = now.strftime("migration_%Y-%m-%b-%d_%H.%M.%S.rb")
    content = <<-eos
require "maglev_record"
require "time"

MaglevRecord::Migration.new(Time.parse("#{now.to_s}"), " description ") do

  def up
    # put your code here
  end

  def down
    # replace the next line with your downcode
    raise IrreversibleMigration, "The migration has no downcode"
  end

end
    eos
    filepath = File.join(MIGRATION_FOLDER, filename)
    File.open(filepath, 'w') { |file| 
      file.write(content)
    }
    puts "created migration #{filepath}"
  end
end

