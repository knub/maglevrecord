require "maglev_record"
require "logger"
require "fileutils"

MIGRATION_FOLDER = "./migrations"
MODEL_FILES = Array.new(Dir.glob("./app/models/*.rb"))

desc "transform the maglev database"
namespace :migrate do

  desc "set up the project for migrations"
  task :setup do
    # puts "PID: #{Process.pid} stone: #{Maglev::System.stone_name}"
    FileUtils.mkpath(MIGRATION_FOLDER) unless File.directory?(MIGRATION_FOLDER)
  end

  desc "migrate all the migrations in the migration folder"
  task :up => [:setup, :load_all_models] do
    migrator = MaglevRecord::Migrator.for_directory(MIGRATION_FOLDER)
    migrator.up(Logger.new(STDOUT))
    Maglev::PERSISTENT_ROOT[:last_snapshot] = MaglevRecord::Snapshot.new
    Maglev.commit_transaction
  end

  desc "show which migrations would be done by up"
  task :up? => :setup do
    # TODO: test
    migrator = MaglevRecord::Migrator.for_directory(MIGRATION_FOLDER)
    migrator.up?(Logger.new(STDOUT))
  end

  desc "create a new migration in the migration folder"
  task :new => :setup do
    MaglevRecord::Migration.write_to_file(MIGRATION_FOLDER,
                                          'fill in description here')
  end

  desc "create a migration file for the changes shown by migrate:auto?"
  task :auto => :setup do
    last_snapshot = Maglev::PERSISTENT_ROOT[:last_snapshot]
    if last_snapshot.nil?
      puts "rake migrate:up has to be done first"
      break
    end
    changes = last_snapshot.changes_in_files(MODEL_FILES)
    if changes.nothing_changed?
      puts "# no changes"
      break
    end
    upcode = changes.migration_string(4)
    file_name = MaglevRecord::Migration.write_to_file(MIGRATION_FOLDER,
                                          'fill in description here',
                                          upcode)
    puts file_name
  end

  desc "show the changes since the last migrate:auto or migrate:up"
  task :auto? do
    last_snapshot = Maglev::PERSISTENT_ROOT[:last_snapshot]
    if last_snapshot.nil?
      puts "rake migrate:up has to be done first"
      break
    end
    changes = last_snapshot.changes_in_files(MODEL_FILES)
    if changes.nothing_changed?
      puts "# no changes"
    else
      puts changes.migration_string
    end
  end

  task :load_all_models do
    Maglev.abort_transaction
    MODEL_FILES.each do |model_file_path|
      load model_file_path
    end
    Maglev.commit_transaction
  end

end

