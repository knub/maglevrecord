require "more_asserts"
require "fileutils"
require "tmpdir"

PROJECT_TMP_DIRECTORY =

#
# this test creates a temporary directory for the test
#

class TempDirTest < Test::Unit::TestCase
  def setup
    # make temporary directory
    # see http://ruby-doc.org/stdlib-2.0/libdoc/tmpdir/rdoc/Dir.html#method-c-mktmpdir
    @tempdir = Dir.mktmpdir
  end

  def teardown
    # remove the directory.
    FileUtils.remove_dir tempdir
  end

  def tempdir
    @tempdir
  end

  # test the project configuration

  def test_tempdir_exists
    assert File.directory?(tempdir)
  end

end
  
class ProjectTest < TempDirTest
  attr_reader :maglev_record_raketask_wd

  def setup
    super
    @project_name = 'project1' if @project_name.nil?
    # copy the project over to the tempdir
    FileUtils.cp_r(project_source_directory, tempdir)
    # change to the project directory to easyly run rake
    @maglev_record_raketask_wd = FileUtils.getwd
    FileUtils.chdir(project_directory)
    # link maglevrecord for require
    assert `ln -s #{maglev_record_raketask_wd} maglevrecordgem`
  end

  def teardown
    super
    FileUtils.chdir(@maglev_record_raketask_wd)
  end

  def project_directory
    File.join(tempdir, @project_name)
  end

  def project_source_directory
    File.join(File.dirname(__FILE__), 'projects', @project_name)
  end

  def test_there_is_a_rakefile_in_the_project_directory
    assert File.file?(File.join(project_directory, 'Rakefile'))
    assert File.file?(File.join(project_source_directory, 'Rakefile'))
  end

  def test_cwd_is_project_directory
    assert_equal FileUtils.getwd, project_directory
  end

  def rake(args)
    ``
    output = IO.popen("export MAGLEV_OPTS=\"-W0 --stone #{Maglev::System.stone_name}\";bundle exec rake " + args) { |f|
      s = line = ''
      while not line.nil?
        s += line
        line = f.gets
      end
      output = s
    }
    output
  end
end

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




