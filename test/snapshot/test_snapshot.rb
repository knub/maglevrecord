require "maglev_record"
require "more_asserts"

class SnapshotTest < Test::Unit::TestCase
  
  # the file with the content of what shell be snapshot
  def self.module_file_path
    # todo: pot this into a temp dir
    'module_content.rb'
  end

  # the file content that snapshots
  def self.snapshot_content
    <<-EOF
      $LOAD_PATH << "lib"
      require "rubygems"
      require "maglev_record"
      load "#{module_file_path}"
      Maglev::PERSISTENT_ROOT['test_snapshot'] = MaglevRecord::Snapshot.new
      Maglev.commit_transaction
      puts "exited successfully!"
    EOF
  end

  # the path of the file that snapshots
  def self.snapshot_file_path
    filepath = 'caller_content.rb'
    File.open(filepath, 'w') { |file| file.write(snapshot_content) }
    filepath
  end

  #
  # snapshot the program after the sting was executed
  # returns the snapshot and aborts the transaction
  #
  def self.snapshot(module_content)
    File.open(module_file_path, 'w') { |file| file.write(module_content) }
    stone = Maglev::System.stone_name
    command =  "export MAGLEV_OPTS=\"-W0 --stone #{stone}\" && "
    command += "bundle exec "
    command += "maglev-ruby #{snapshot_file_path}"
    puts command
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
    Maglev.abort_transaction
    raise AssertionFailedError, "snapshotting exited with error" unless  exit_status == 0
    Maglev::PERSISTENT_ROOT['test_snapshot']
  end

  def self.shutdown
    File.delete(snapshot_file_path)
    File.delete(module_file_path) if File.file?(module_file_path)
    clean
  end

  #
  # compare two sources and return the MaglevRecord Snapshot
  #
  def self.compare(s1, s2)
    s1 = snapshot(s1)
    s2 = snapshot(s2)
    s2.changes_since(s1)
  end

  def self.class_string(name, content = '')
    "class MyTestClass
      include MaglevRecord::Base
      self.maglev_persistable(true)
      # content follows
      #{content}
      # content ends
    end"
  end

  as_instance_method :class_string, :compare, :snapshot

  def self.clean
    consts = [:MyTestClass, :MyTestClass2]
    consts.each { |const|
      begin
        Object.remove_const(const)
      rescue NameError
      end
    }
  end

  def test_class_string_include_class_name
    s = class_string('MyTestClass', 'xxxx')
    assert_include? s, 'class MyTestClass'
    assert_include? s, 'xxxx'
  end

end
