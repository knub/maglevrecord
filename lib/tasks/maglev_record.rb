require "lib/maglev_record/migration"

MIGRATION_FOLDER = "test/migration/dummy_migrations"
namespace :db do
  task :migrate do
    Rake::Task['db:migrate'].clear
    loader = MaglevRecord::MigrationLoader.new
    loader.load_directory(MIGRATION_FOLDER)
    migrator = MaglevRecord::Migrator.new(loader.migration_list)
    migrator.up
  end
end
