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
    #FileUtils.remove_dir tempdir
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
    FileUtils.chdir(@maglev_record_raketask_wd)
    #FileUtils.remove_dir(project_directory)
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
    output = IO.popen("bundle exec rake " + args) { |f|
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

class Project1Test < ProjectTest

  def test_transformations_are_listed
    output = rake("-T")
    assert_include? output, 'rake transform:new'
    assert_include? output, 'rake transform:up'
  end

  def test_no_transformation_on_start
    assert_not File.directory?('./transformations')
  end

  def test_new_transformation
    rake("transform:new")
    assert File.directory? './transformations'
    assert_not_equal [], Dir[File.join(FileUtils.pwd, 'transformations', '*')]
  end

end




