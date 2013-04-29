require "maglev_record"
require "more_asserts"

class SnapshotTest < Test::Unit::TestCase
  
  # the file with the content of what shell be snapshot
  def module_file_path
    # todo: pot this into a temp dir
    'module_content.rb'
  end

  # the file content that snapshots
  def snapshot_content
    <<-EOF
      $LOAD_PATH << "lib"
      require "maglev_record"
      load "#{module_file_path}"
      Maglev::PERSISTENT_ROOT['test_snapshot'] = MaglevRecord::Snapshot.new
      Maglev.commit_transaction
      puts "exited successfully!"
    EOF
  end

  # the path of the file that snapshots
  def snapshot_file_path
    filepath = 'caller_content.rb'
    File.open(filepath, 'w') { |file| file.write(snapshot_content) }
    filepath
  end

  #
  # snapshot the program after the sting was executed
  # returns the snapshot and aborts the transaction
  #
  def snapshot(module_content)
    File.open(module_file_path, 'w') { |file| file.write(module_content) }
    stone = Maglev::System.stone_name
    command =  "export MAGLEV_OPTS=\"-W0 --stone #{stone}\" && "
    command += "bundle exec maglev-ruby #{snapshot_file_path}"
    exit_status = IO.popen(command) { |f|
      line = f.gets
      status = 1 # $? does not work here so we work around
      while not line.nil?
        if line.chomp == "exited successfully!"
          status = 0
        else
          puts line
          status = 1
        end
        line = f.gets
      end
      status
    }
    assert_equal exit_status, 0, "snapshotting exited with error"
    Maglev.abort_transaction
    Maglev::PERSISTENT_ROOT['test_snapshot']
  end

  def teardown
    File.delete(snapshot_file_path)
    File.delete(module_file_path) if File.file?(module_file_path)
    clean
  end

  #
  # compare two sources and return the MaglevRecord Snapshot
  #
  def compare(s1, s2)
    s1 = snapshot(s1)
    s2 = snapshot(s2)
    s2.changes_since(s1)
  end

########################## TEST

  def clean
    consts = [:MyTestClass, :MyTestClass2]
    consts.each { |const|
      begin
        Object.remove_const(const)
      rescue NameError
      end
    }
  end

  def test_has_changes
    changes = compare('', '')
    assert_not_nil changes
  end
end


class ClassSnapshotTest < SnapshotTest

  def test_new_class
    changes = compare('', 'class MyTestClass; include MaglevRecord::Base; end')
    assert_not_equal [], changes.new_classes
    classdiv = changes.new_classes[0]
    assert_equal classdiv.class_name, 'MyTestClass'
    assert_equal classdiv.class, MyTestClass
  end

  def test_class_removed
    changes= compare('class MyTestClass2; include MaglevRecord::Base; end', '')
    assert_not_equal [],  changes.removed_classes
    classdiv = changes.removed_classes[0]
    assert_equal classdiv.class_name, 'MyTestClass'
    assert_nil classdiv.class, 'this class was removed: there should not be a reference to it'
  end

end

class AttrSnapshotTest < SnapshotTest

  def changes
    @changes
  end

  def setup
    super
    @changes = compare('
      class MyTestClass2
        include MaglevRecord::Base
        attr_accessor :no_value, :lala
      end', '
      class MyTestClass2; include MaglevRecord::Base
        attr_accessor :students, :lala
      end')
  end

  def test_no_class_removed
    assert_equal changes.removed_classes, []
  end

  def test_class_changed
    assert_equal changes.changed_classes.size, 1
  end

  def test_no_class_was_added
    assert_equal changes.new_classes, []
  end

  def changed_class
    assert_not_nil changes.changed_classes[0], 'a class must have changed'
    changes.changed_classes[0]
  end

  def test_accessor_added
    assert_equal changed_class.new_attr_accessor, [:students]
  end

  def test_accessor_removed
    assert_equal changed_class.new_attr_accessor, [:no_value]
  end

end
