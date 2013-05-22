require 'maglev_record'
require "temp_dir_test"
require 'more_asserts'

class FileSystemSnapshotTest < TempDirTest

  def setup
    super
    Maglev.begin_nested_transaction
    @file_count = 0
  end

  def teardown
    super
    Maglev.abort_transaction
  end

  def write_to_file(content, file_path = File.join(tempdir, "x#{@file_count += 1}.rb"))
    File.open(file_path, 'w'){ |f| f.write content}
    file_path
  end

  def write_to_files(*file_contents)
    file_paths = []
    file_contents.each{ |content|
      file_paths << write_to_file(content)
    }
    file_paths
  end

  def snapshot_with_files(*file_contents)
    file_paths = write_to_files(*file_contents)
    MaglevRecord::Snapshot.with_files file_paths
  end

  def changes_with_files(s, *file_contents)
    @file_count = 0
    if s.is_a? String
      file_contents << s
      s = nil
    end
    s = MaglevRecord::Snapshot.new if s.nil?
    file_paths = write_to_files(*file_contents)
    s.changes_in_files file_paths
  end

  def test_new_class
    s = snapshot_with_files "class SomeClass;include MaglevRecord::Base;end"
    assert_include? s.snapshot_classes, SomeClass
  end

  def test_old_clases_are_loaded_too
    file_path = write_to_file "class AnotherClass; include MaglevRecord::Base;def x;end;end"
    Kernel.load file_path
    s0 = MaglevRecord::Snapshot.new
    write_to_file "class AnotherClass; include MaglevRecord::Base;def y;end;end", file_path
    s = snapshot_with_files "class SomeClass2;include MaglevRecord::Base;def v;end;end"
    assert_include? s.snapshot_classes, AnotherClass
    assert_include? s.snapshot_classes, SomeClass2
    assert_include? s.changes_since(s0).changed_classes, AnotherClass
  end

  def test_snapshot_computes_changes
    c = changes_with_files "class NewClass;include MaglevRecord::Base;def g;end;end"
    assert_include? c.new_classes, NewClass
  end

  def test_many_changes
    s = snapshot_with_files "class A; include MaglevRecord::Base; def g; end;end",
               "class Class2; include MaglevRecord::Base; attr_accessor :tral;end"
    c = changes_with_files "class A; include MaglevRecord::Base; def h; end;end",
               "class Class2; include MaglevRecord::Base; attr_accessor :tral2;end",
               "class NewCls; include MaglevRecord::Base; def c;end ;end"
    assert_equal "xxx", c.migration_string
  end

  def test_changes_in_files_loads_all_files_required
    file_path = write_to_file "class TheClass; include MaglevRecord::Base;def x;end;end"
    Kernel.load file_path
    write_to_file "class TheClass; include MaglevRecord::Base;def y;3;end;end", file_path
    file_paths = [write_to_file "class TheNew;include MaglevRecord::Base; def g;end;end"]
    changes = s.changes_in_files(file_paths)
    assert_include? changes.new_classes, TheNew
    assert_include? changes.changed_classes, TheClass
    assert_raises(NoMethodError){
      TheClass.new.x
    }
    assert_equal 3, TheClass.new.y
    assert_equal changes[TheClass].new_instance_methods, ["y"]
    assert_equal changes[TheClass].removed_instance_methods, ["x"]
  end

  def test_file_was_removed
    file_path = write_to_file "class ClassWithNoFuture; include MaglevRecord::Base;def h;endlend"
    Kernel.load file_path
    File.remove file_path
    s = MaglevRecord::Snapshot.new_with_files
    assert_not_include? s.class_names, 'ClassWithNoFuture'
  end

end






