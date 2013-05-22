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
    assert s.is_a?(MaglevRecord::Snapshot), s.to_s
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
    assert_include? s.changes_since(s0).changed_class_names, "AnotherClass"
  end

  def test_snapshot_computes_changes
    c = changes_with_files "class NewClass;include MaglevRecord::Base;def g;end;end"
    assert_include? c.new_class_names, 'NewClass'
  end

  def test_many_changes
    s = snapshot_with_files "class A; include MaglevRecord::Base; def g; end;end",
               "class Class2; include MaglevRecord::Base; attr_accessor :tral;end"
    c = changes_with_files "class A; include MaglevRecord::Base; def h; end;end",
               "class Class2; include MaglevRecord::Base; attr_accessor :tral2;end",
               "class NewCls; include MaglevRecord::Base; def c;end ;end"
    # the following line may change some day but it can help debugging
    assert_equal "#new class: NewCls\n#new instance method: A.new.h\nA.remove_instance_method :g\n#new accessor :tral2 of Class2\n#new instance method: Class2.new.tral2\n#new instance method: Class2.new.tral2=\nClass2.remove_instance_method :tral\nClass2.remove_instance_method :tral=", c.migration_string
  end

  def test_changes_in_files_loads_all_files_required
    file_path = write_to_file "class TheClass; include MaglevRecord::Base;def x;end;end"
    Kernel.load file_path
    s = MaglevRecord::Snapshot.new
    write_to_file "class TheClass; include MaglevRecord::Base;def y;3;end;end", file_path
    file_paths = [write_to_file "class TheNew;include MaglevRecord::Base; def g;end;end"]
    changes = s.changes_in_files(file_paths)
    assert_include? changes.new_class_names, 'TheNew'
    assert_include? changes.changed_class_names, 'TheClass'
    assert_raises(NoMethodError){
      TheClass.new.x
    }
    assert_equal 3, TheClass.new.y
    assert_equal changes[TheClass].new_instance_methods, ["y"]
    assert_equal changes[TheClass].removed_instance_methods, ["x"]
  end

  def test_file_was_removed
    file_path = write_to_file "class ClassWithNoFuture; include MaglevRecord::Base;def h;end;end"
    s = MaglevRecord::Snapshot.with_files [file_path]
    File.delete file_path
    changes = s.changes_in_files
    assert_include? changes.removed_class_names, 'ClassWithNoFuture'
  end

end


# TODO: test that attributes are affected by automigrations



