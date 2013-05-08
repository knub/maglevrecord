require "migration/test_project.rb"

class NeedMigrateUpBeforeAutomigration < ProjectTest

  def setup
    Maglev.abort_transaction
    @project_name = 'project2'
    super
    Maglev::PERSISTENT_ROOT[:last_snapshot] = nil
    Maglev.commit_transaction
  end

  def teardown
    super
    Maglev.abort_transaction
  end

  def test_no_snapshot_at_start
    assert_nil Maglev::PERSISTENT_ROOT[:last_snapshot]
  end

  def migrate_up_creates_a_snapshot
    rake('migrate:up')
    Maglev.abort_transaction
    snap = Maglev::PERSISTENT_ROOT[:last_snapshot]
    assert_not_nil snap
    assert_include? snap.snapshot_classes, ProjectModel
  end

  def test_migrate_auto_without_initial_snapshot_does_not_work
    rake_output = rake('migrate:auto')
    assert_equal "rake migrate:up has to be done first", rake_output
  end

  def test_migrate_auto2_without_initial_snapshot_does_not_work
    rake_output = rake('migrate:auto?')
    assert_equal "rake migrate:up has to be done first", rake_output
  end

end
