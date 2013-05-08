require "maglev_record/migration"
require "maglev_record/snapshot"
require "time"
require "logger"
require "fileutils"

MIGRATION_FOLDER = "migrations"
MODEL_PATHS = ["./app/models/*.rb"]

desc "transform the maglev database"
namespace :migrate do

  desc "set up the project for migrations"
  task :setup do
    # puts "PID: #{Process.pid} stone: #{Maglev::System.stone_name}"
    FileUtils.mkpath(MIGRATION_FOLDER) unless File.directory?(MIGRATION_FOLDER)
  end

  desc "migrate all the migrations in the migration folder"
  task :up => [:setup, :load_all_models] do
    loader = MaglevRecord::MigrationLoader.new
    loader.load_directory(MIGRATION_FOLDER)
    migrator = MaglevRecord::Migrator.new(loader.migration_list)
    logger = Logger.new(STDOUT)
    migrator.up(logger)
    Maglev.abort_transaction
    Maglev::PERSISTENT_ROOT[:last_snapshot] = MaglevRecord::Snapshot.new
    Maglev.commit_transaction
  end

  desc "create a new migration in the migration folder"
  task :new => :setup do
    MaglevRecord::Migration.write_to_file(MIGRATION_FOLDER,
                                          'fill in description here')
  end

  desc "create a migration file for the changes shown by migrate:auto?"
  task :auto => [:setup, :load_all_models] do
    last_snapshot = Maglev::PERSISTENT_ROOT[:last_snapshot]
    if last_snapshot.nil?
      puts "rake migrate:up has to be done first"
      break
    end
    changes = MaglevRecord::Snapshot.new.changes_since(last_snapshot)
    upcode = changes.migration_string(4)
    MaglevRecord::Migration.write_to_file(MIGRATION_FOLDER,
                                          'fill in description here',
                                          upcode)
  end

  desc "show the changes since the last migrate:auto or migrate:up"
  task :auto? => :load_all_models do
    last_snapshot = Maglev::PERSISTENT_ROOT[:last_snapshot]
    if last_snapshot.nil?
      puts "rake migrate:up has to be done first"
      break
    end
    changes = MaglevRecord::Snapshot.new.changes_since(last_snapshot)
    migration_string = changes.migration_string
    if migration_string == ""
      puts "# no changes"
    else
      puts migration_string
    end
  end

  task :load_all_models do
    Maglev.abort_transaction
    Dir.glob(MODEL_PATHS).each do |model_file_path|
      load model_file_path
    end
    Maglev.commit_transaction
  end

end

