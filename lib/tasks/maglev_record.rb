require "maglev_record"

MIGRATION_FOLDER = "test/migration/dummy_migrations"
namespace :db do
  task :migrate do
    Maglev.abort_transaction
    Rake::Task['db:migrate'].clear
    loader = MaglevRecord::MigrationLoader.new
    loader.load_directory(MIGRATION_FOLDER)
    migrator = MaglevRecord::Migrator.new(loader.migration_list)
    migrator.up
    begin
      Maglev.commit_transaction
    rescue TransactionError => e
      puts Maglev::PERSISTENT_ROOT
      puts e
    end
  end
end
