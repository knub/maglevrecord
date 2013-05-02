require "more_asserts"
require "example_model"

class MigrationScenarioTest < Test::Unit::TestCase
  Migration = MaglevRecord::Migration
  MigrationLoader = MaglevRecord::MigrationLoader
  Migrator = MaglevRecord::Migrator

  attr_reader :loader

  def setup
    MaglevRecord.reset
    RootedBook.clear
    Maglev::PERSISTENT_ROOT[Migrator::MIGRATION_KEY] = Array.new
    @loader = MigrationLoader.new
    RootedBook.new(:title => "Harry Potter and the Philosopher's stone")
    RootedBook.new(:title => "Harry Potter and the Chamber of Secrets")
    RootedBook.new(:title => "Harry Potter and the Prisoner of Azkaban")
    MaglevRecord.save
    loader.load_directory(migration_directory)
  end

  def migration_directory
    File.dirname(__FILE__) + '/migrations'
  end

  def test_migration_loader_loads_correct_number_of_migrations
    assert_equal 3, loader.migration_list.size
  end

  def test_migration_loader
    migration_list = loader.migration_list
    migrator = Migrator.new(migration_list)
    migrator.up
    assert_equal "The most recent book title", RootedBook.first.title
  end
end
