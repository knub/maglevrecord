require "maglev_record"

puts $LOAD_PATH

MIGRATION_FOLDER = "./migrations"
namespace :db do
  task :migrate do
    puts "Loading migrations."
    loader = MaglevRecord.MigrationLoader.new
    loader.load_directory(MIGRATION_FOLDER)
    migrator = MaglevRecord.Migrator.new(loader.migration_list)
    migrator.up
  end
end
