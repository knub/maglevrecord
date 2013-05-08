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
    now = Time.now
    filename = now.strftime("migration_%Y-%m-%b-%d_%H.%M.%S.rb")
    content = MaglevRecord::Migration.file_content(now, 'fill in description here')
    filepath = File.join(MIGRATION_FOLDER, filename)
    File.open(filepath, 'w') { |file| 
      file.write(content)
    }
    puts "created migration #{filepath}"
  end

  desc "create a migration file for the changes shown by migrate:auto?"
  task :auto => :setup do
    last_snapshot = Maglev::PERSISTENT_ROOT[:last_snapshot]
    if last_snapshot.nil?
      puts "rake migrate:up has to be done first"
      break
    end
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

