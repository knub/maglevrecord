require "maglev_record/migration"
require "time"
require "logger"
require "fileutils"

MIGRATION_FOLDER = "migrations"

desc "transform the maglev database"
namespace :migrate do

  desc "set up the project for migrations"
  task :setup do
    # puts "PID: #{Process.pid} stone: #{Maglev::System.stone_name}"
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
    content = MaglevRecord::Migration.file_content(now, 'fill in description here')
    filepath = File.join(MIGRATION_FOLDER, filename)
    File.open(filepath, 'w') { |file| 
      file.write(content)
    }
    puts "created migration #{filepath}"
  end
end

