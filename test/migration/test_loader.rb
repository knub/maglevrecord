require "maglev_record"
require "more_asserts"

class TestMigrationLoader < Test::Unit::TestCase

  def setup
    @loader = MaglevRecord::MigrationLoader.new
    @m1 = <<-MIGRATION1
Migration.new(Time.utc(2013, 2, 1, 10, 0, 0, 0), "Change book title") do
  def up
    Book.each do |book|
      book.title = "A new book title"
    end
  end
  def down
    Book.each do |book|
      book.title = "Back to old title"
    end
  end
end
MIGRATION1

    @m2 = <<-MIGRATION2
Migration.new(Time.utc(2014, 2, 1, 10, 0, 0, 0), "Change book title again") do
  def up
    Book.each do |book|
      book.title = "A even newer book title"
    end
  end
  def down
    Book.each do |book|
      book.title = "A new book title"
    end
  end
end
MIGRATION2
  end

  def migration_folder
    File.dirname(__FILE__) + '/migrations/'
  end

  def test_load_simple_migration
    assert_equal 0, @loader.migration_list.size
    @loader.load_string @m1
    assert_equal 1, @loader.migration_list.size
    assert @loader.migration_list.any? { |m| m.name == "Change book title" }
  end

  def test_load_several_migrations
    assert_equal @loader.migration_list.size, 0
    @loader.load_string @m1
    @loader.load_string @m2
    assert_equal @loader.migration_list.size, 2
    assert_equal 2013, @loader.migration_list.first.timestamp.year
    assert_equal 2014, @loader.migration_list.last.timestamp.year
  end

  def test_correct_migration_order
    # load in wrong order, must be in correct order afterwards
    @loader.load_string @m2
    @loader.load_string @m1
    assert_equal 2013, @loader.migration_list.first.timestamp.year
    assert_equal 2014, @loader.migration_list.last.timestamp.year
  end

  def test_load_from_file
    @loader.load_file(migration_folder + 'migration_1.rb')
    assert @loader.migration_list.any? { |m| m.name == "Change book title" }
  end

  def test_load_directory
    @loader.load_file(migration_folder + 'migration_1.rb')
    @loader.load_directory(migration_folder)
    assert_equal 3, @loader.migration_list.size
  end

end
