require "test/unit"
require "maglev_record"
require "more_asserts"

class TestTimestamp_parse < Test::Unit::TestCase
  class T < MaglevRecord::MigrationContext::Timestamp
  end

  def test_create_from_string
    t = T.parse('2012-10-2 20:21:24 223ms +03:00')
    assert_equal t.year, 2012
    assert_equal t.month, 10
    assert_equal t.day, 2
    assert_equal t.hour, 23
    assert_equal t.minute, 21
    assert_equal t.second, 24
    assert_equal t.millisecond, 223
  end

  def test_to_s
    s = '2032-1-22 22:01:4 23ms +03:00'
    t = T.parse(s)
    assert_equal s, t.to_s
  end

  def test_compare_timzone_differs
    s = '2012-3-23 10:11:12 012ms '
    t1 = T.parse(s + "+00:00")
    t2 = T.parse(s + "+01:00")
    assert t1 < t2
    assert t1.hash != t2.hash
  end

  def test_compare_equal
    s = '2135-02-22 10:20:10 333ms +00:00'
    t1 = T.parse(s)
    t2 = T.parse(' ' + s + ' ')
    assert_equal t1, t1
    assert_equal t1, t2
    assert_equal t2, t1
    assert_equal t2, t2

    assert_equal t1.hash, t1.hash
    assert_equal t1.hash, t2.hash
    assert_equal t2.hash, t1.hash
    assert_equal t2.hash, t2.hash
  end
  
  # TODO: make sure the timestamp is correctly comparable
  
  def test_include_in_array
    s = '1990-12-21 22:21:20 +00:00'
    t1 = T.parse(s)
    t2 = T.parse(s)
    assert [t1].include?(t1)
    assert [t1].include?(t2)
    assert [[t1]].include?([t1])
    assert [[t1]].include?([t2])
  end


end

class TestTimestamp_with_migration <  Test::Unit::TestCase
  class T < MaglevRecord::MigrationContext::Timestamp
  end

  class M < MaglevRecord::Migration
  end

  def test_can_use_timestamp_for_migration
    t = T.parse('2003-2-2 3:3:32 +00:00')
    m = M.with_timestamp(t)
    assert_equal m.timestamp, t
    assert_equal m.timestamp, T.parse('2003-2-2 3:3:32 +00:00')
  end

  def test_migrations_are_identified_by_timestamp
    t1 = T.parse('2033-3-4 5:6:2 +03:00')
    t2 = T.parse('2033-3-4 4:6:2 +04:00')
    m1 = M.with_timestamp(t1)
    m2 = M.with_timestamp(t2)
    assert_equal t1, t2
    assert_equal m1, m2
  end

end

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
  # get the MalgevRecordTimestamp
  #

  class T < MaglevRecord::MigrationContext::Timestamp
  end

  # 
  # This migration factory creates the migrations we use
  #
  class MigrationFactory
    def initialize
      @args = []
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
    
    attr_reader :timestamp, :parent
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

  def timestamp(string)
    C::Timestamp.parse(string)
  end

  attr_reader :migration_directory, :f, :c

  def test_get_first_migration
    c.load_string "\n\n\n migration('2012-12-21 21:12:12 0ms +00:00').follows(first_migration)\n"
    assert_equal f.migrations[0].parent, f
  end

  def test_create_migration
    v = c.load_string "\n\n\n  migration('2012-10-2 20:20:20 0ms +03:00')"
    assert_equal f.args, [[timestamp('2012-10-2 20:20:20 0ms +03:00')]]
  end

  def test_load_from_file
    filename = migration_directory + 'migration_1.rb'
    c.load_file filename
    # "2013-01-22 18:31:11"
    assert_equal f.args, [[timestamp("2013-01-22 18:31:11 +00:00")]]
  end

  def test_load_nonexistent_file
    # make sure this file does not exists before test
    assert !File.file?('hajksdjkhkahdjkasjk')

    # test
    assert_raise(ArgumentError) {
      c.load_file 'hajksdjkhkahdjkasjk'
    }
  end

  def test_load_directory
    c.load_directory(migration_directory)
    assert_include?(f.args, [timestamp("2012-01-22 19:01:01 +00:00")]) # "2012-01-22 19:01:01"
    assert_include?(f.args, [timestamp("2013-01-22 18:31:11 +00:00")]) # "2013-01-22 18:31:11"
  end

  def test_call_the_special_method
    assert_equal c.method_called, nil
    c.load_string "#test da method call!\na_method_for_migrations"
    assert_equal c.method_called, 1
  end

  def assert_arg(argument)
    assert_equal f.args[0], [argument]
  end

  def test_converting_from_timestamp
    c.load_string "\nmigration('2014-02-21 07:33:21 0ms +06:00')"
    assert_arg(timestamp('2014-02-21 07:33:21 0ms +06:00'))
  end

  def test_bad_time_format
    assert_raise(C::Timestamp::BadTimeFormat){
      c.migration('jaskldjlajlkd')
    }
  end

  def test_get_source_of_migration
    s = "\nmigration('2012-2-3 4:3:1 0ms +00:00')"
    c.load_string s
    assert_equal f.migrations[0].source, s
  end

  def test_file_source_of_migration
    path = migration_directory + 'migration_2.rb'
    real_source = File.open(path).read
    c.load_file path
    assert_equal f.migrations[0].source, real_source
  end

end



