require "migration/test_project"

class MigrationTestProject1 < ProjectTest

  def setup
    super
    Maglev.abort_transaction
    Maglev::PERSISTENT_ROOT['test_apply'] = "it was not set"
    Maglev.commit_transaction
  end

  def test_tasks_are_listed
    output = rake("-T")
    assert_include? output, 'rake migrate:new'
    assert_include? output, 'rake migrate:up'
  end

  def test_no_folder_on_start
    assert_not File.directory?('./migrations')
  end

  def test_new
    rake("migrate:new")
    assert File.directory? './migrations'
    assert_not_equal [], Dir[File.join(FileUtils.pwd, 'migrations', '*')]
  end

  def test_no_apply
    Maglev.abort_transaction
    assert_not_equal 'it was set', Maglev::PERSISTENT_ROOT['test_apply']
  end

  def test_apply
    upcode = "Maglev::PERSISTENT_ROOT['test_apply'] = 'it was set'"
    Dir.mkdir('./migrations')
    File.open('./migrations/example_migration.rb', 'w') { |file|
      file.write(MaglevRecord::Migration.file_content(
                            Time.now, "test_apply_migration",
                            upcode)
      )
    }
    s = rake('migrate:up')
    #p '-' * 30
    #p s
    Maglev.abort_transaction
    assert_equal 'it was set', Maglev::PERSISTENT_ROOT['test_apply']
  end

end




