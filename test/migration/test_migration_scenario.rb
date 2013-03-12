require "maglev_record"
require "more_asserts"

require "example_model"

class MigrationScenarioTest < Test::Unit::TestCase
  Migration = MaglevRecord::Migration
  MigrationLoader = MaglevRecord::MigrationLoader
  Migrator = MaglevRecord::Migrator

  Maglev.persistent do
    load File.dirname(__FILE__) + '/../example_model.rb'
  end

  attr_reader :loader

  def setup
    MaglevRecord.reset

    Book.clear
    @loader = MigrationLoader.new
    Book.new(:title => "Harry Potter and the Philosopher's stone")
    Book.new(:title => "Harry Potter and the Chamber of Secrets")
    Book.new(:title => "Harry Potter and the Prisoner of Azkaban")
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
    #assert_equal "The most recent book title", Book.first.title
  end
end
