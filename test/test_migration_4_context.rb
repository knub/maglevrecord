require "test/unit"
require "maglev_record"

class TestMigrationContext_load < Test::Unit::TestCase
  #
  # create a context class with our special method we want to use
  # when creating a migration
  #
  class C < MaglevRecord::MigrationContext
    attr_reader :method_called
    def a_method_for_migrations
      @method_called = 0 if @method_called.nil?
      @method_called += 1
    end
  end

  # 
  # This migration factory creates the migrations we use
  #
  class MigrationFactory
    def initialize
      @args
      @migrations = []
    end
    def migration(*args)
      @args << args     
      m = MockMigration.new(*args)
      @migrations << m
      m
    end

    attr_reader :migrations, :args

    def first_migration
      self
    end
  end

  class MockMigration
    
    attr_reader :timestamp
    attr_accessor :source

    def initialize(timestamp)
      @timestamp = timestamp
    end

    def follows(parent)
      @parent = parent
    end
  end

  def setup
    @f = MigrationFactory.new
    @c = C.new(f)
    @migration_directory = File.dirname(__FILE__) + '/_migrations/'
    assert File.directory?(migration_directory)
    assert (File.file? migration_directory + 'migration_1.rb')
    assert (File.file? migration_directory + 'migration_2.rb')
  end

  attr_reader :migration_directory, :f, :c

  def test_get_first_migration
    c.load_string "\n\n\n migration('2012-12-21 21:12:12 +00:00').follows(first_migration)\n"
    assert_equal f.migrations[0].parent, f
  end

  def test_create_migration
    v = c.load_string "\n\n\n  migration('2012-10-2 20:20:20 +03:00')"
    assert_equal f.args, [Time.new(2012, 10, 2, 20, 20, 20, '+03:00')]
  end

  def test_load_from_file
    filename = migration_directory + 'migration_1.rb'
    c.load_file filename
    assert_equal l.args [["2013-01-22 18:31:11"]] # TODO: timestamp
  end

  def test_load_nonexistent_file
    # make sure this file does not exists before test
    assert !File.file?('hajksdjkhkahdjkasjk')

    # test
    assert_raise(Exception) {
      c.load_file 'hajksdjkhkahdjkasjk'
    }
  end

  def test_load_directory
    c.load_directory(migration_directory)
    assert f.args.include?(["2012-01-22 19:01:01"]) # TODO: timestamp
    assert f.args.include?(["2013-01-22 18:31:11"]) # TODO: timestamp
  end

  def test_call_the_special_method
    assert_equal c.method_called, nil
    c.load_string "#test da method call!\na_method_for_migrations"
    assert_equal c.method_called, 1
  end
  
  def assert_arg(argument)
    assert_equal f.args[0], argument
  end

  def test_converting_from_timestamp
    # TODO ! create timestamp
    c.load_string "\nmigration('2014-02-21 07:33:21 +06:00')"
    assert_arg(Time.new(2014, 2, 21, 7, 33, 21, "+06:00"))
  end

  def test_bad_time_format
    assert_raise{
      c.migration('jaskldjlajlkd')
    }
  end

  def test_get_source_of_migration
    s = "\nmigration('2012-2-3 4:3:1 +00:00')"
    c.load_string s
    assert_equals f.migrations[0].source, s
  end

  def test_file_source_of_migration
    path = migration_directory + 'migration_2.rb'
    real_source = File.open(path).read
    c.load_file path
    assert_equal f.migrations[0].source, real_source
  end

end



