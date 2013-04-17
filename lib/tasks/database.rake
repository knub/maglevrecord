require "maglev_record/migration"
require "time"
require "logger"
require "fileutils"

MIGRATION_FOLDER = "transformations"

desc "transform the maglev database"
namespace :transform do

  desc "set up the project for transformations"
  task :setup do
    FileUtils.mkpath(MIGRATION_FOLDER) unless File.directory?(MIGRATION_FOLDER)
  end

  desc "migrate all the migrations in the migration folder"
  task :up => :setup do
    loader = MaglevRecord::MigrationLoader.new
    loader.load_directory(MIGRATION_FOLDER)
    migrator = MaglevRecord::Migrator.new(loader.migration_list)
    logger = Logger.new(STDOUT)
    migrator.up(logger)
  end

  desc "create a new migration in the migration folder"
  task :new => :setup do
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

