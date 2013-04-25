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
  end

  def test_snapshot
    s = snapshot('')
    fail('need to be implemented here')
  end

end

