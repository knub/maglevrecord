require "migration/test_project.rb"

class RakeTaskTestBase < ProjectTest

  def setup
    Maglev.abort_transaction
    Maglev.persistent do
      @rooted_book = Object.remove_const :RootedBook if defined? RootedBook
    end
    @project_name = 'automigration'
    super
    project_model_source("")
    Maglev.persistent do
      Object.remove_const :ProjectModel if defined?(ProjectModel)
    end
    snapshot!
    Maglev.commit_transaction
    @error_message = nil
  end

  def new_snapshot
    # should only snapshot project model
    classes = MaglevRecord::Snapshotable.snapshotable_classes.select(&:maglev_persistable?)
    classes -= [BaseLecture1, BaseLecture2] if defined? BaseLecture1
    MaglevRecord::Snapshot.new classes
  end

  def snapshot!
    # define the interface that rake should use
    Maglev::PERSISTENT_ROOT[:last_snapshot] = new_snapshot
  end

  def changes
    new_snapshot.changes_since Maglev::PERSISTENT_ROOT[:last_snapshot]
  end

  def teardown
    super
    puts @error_mesage unless @error_message.nil?
    Maglev.abort_transaction
    Object.const_set :RootedBook, @rooted_book unless @rooted_book.nil?
  end

  def project_model_source(string)
    file_path = "app/models/project_model.rb"
    File.open(file_path, 'w') { |file| file.write(string)}
    load file_path
  end

  def test_no_changes_since
    assert_equal [], changes.removed_classes
    assert_equal [], changes.changed_classes
    assert_equal [], changes.new_classes
    assert changes.nothing_changed?
  end

end
