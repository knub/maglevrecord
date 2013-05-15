require "more_asserts"
require "migration/operation_setup"

class FastSnapshotTest < Test::Unit::TestCase

  def lectures
    MaglevRecord::Snapshotable.snapshotable_classes.select{ |cls|
      cls.name.start_with? "Lecture"
    }
  end

  def assert_migration_string(string, *args)
    assert_equal string, changes.migration_string(*args)
  end

  def snapshot
    MaglevRecord::Snapshot.new(lectures)
  end

  def changes
    snapshot.changes_since snapshot0
  end

  def setup
    setup_migration_operations
    snapshot!
  end

  def snapshot!
    @snapshot0 = snapshot
  end

  def snapshot0
    @snapshot0
  end

  def teardown
    teardown_migration_operations
  end

  def remove_class(*classes)
    Maglev.persistent do
      classes.each { |cls|
        Object.remove_const cls.name
        def cls.exists?
          false
        end
      }
    end
  end

  def test_removed_class
    remove_class Lecture
    assert_raise(NameError) {
      Lecture
    }
    assert_not_include? Object.constants, "Lecture"
  end

end


