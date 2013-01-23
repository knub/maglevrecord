require "test/unit"
require "maglev_record"
require "more_asserts"


class TestMigrationLoaderBase < Test::Unit::TestCase
  
  class ML < MaglevRecord::MigrationLoader
    def lalilulalilu
    end
  end

  class ML2 < ML
  end

  def setup
    @l = ML.new
  end

  def teardown
    ML.clear
    ML::Migration.clear
  end

  def l
    @l
  end

  def test_nothing
  end

  def migration_folder
    File.dirname(__FILE__) + '/_migrations/'
  end
end
