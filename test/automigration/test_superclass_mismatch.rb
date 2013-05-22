require 'more_asserts'
require 'temp_dir_test'

class SuperclassOfX
end
class NotSuperclassOfX
end

class SuperclassMismatchMigrationStringTest < TempDirTest

  def setup
    super
    @fp = write_to_file("class X < SuperclassOfX;include MaglevRecord::Base;def h;5;end;end;
                        class Y;include MaglevRecord::Base;attr_accessor :a;end")
    snapshot = MaglevRecord::Snapshot.with_files([@fp])
    write_to_file("class X < NotSuperclassOfX;\ninclude MaglevRecord::Base;def h;end;end
                   class Y;include MaglevRecord::Base;attr_accessor :b;end", @fp)
    @changes = snapshot.changes_in_files
  end

  def changes
    @changes
  end

  def test_no_class_changes_or_was_removed
    assert_equal [], changes.new_class_names
    assert_equal [], changes.removed_class_names
    assert_equal [], changes.changed_class_names, "class Y changed but can not be listed here"
    assert_equal [], changes.new_classes
    assert_equal [], changes.removed_classes
    assert_equal [], changes.changed_classes, "class Y changed but can not be listed here"
  end

  def test_the_state_of_all_classes_is_restored
    assert_equal ['a'], Y.attributes
    assert_equal 5, X.new.h
  end

  def superclass_mismatch_change
    assert_equal 1, changes.superclass_mismatch_classes.size
    changes.superclass_mismatch_classes.first
  end

  def test_class_X_has_the_superclass_mismatch
    assert_equal X, superclass_mismatch_change.mismatching_class
    assert_equal "X", superclass_mismatch_change.class_name
  end

  def test_superclass_mismatch_migration_string
    assert_equal "# TypeError: superclass mismatch for X\n" +
                 #"# class X < NotSuperclassOfX;\n" +
                 #"# in line 1 of #{@fp}\n" + 
                 "# in #{@fp}\n" +
                 "X.remove_superclass", changes.migration_string
  end
end



class NoSuperclassMismatchTest < Test::Unit::TestCase
  def test_no_superclass_mismatch
    s = MaglevRecord::Snapshot.new
    changes = s.changes_since(s)
    assert_equal [], changes.superclass_mismatch_classes
  end

end












