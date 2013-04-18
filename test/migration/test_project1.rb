require "more_asserts"
require "fileutils"
require "tmpdir"

PROJECT_TMP_DIRECTORY =

#
# this test creates a temporary directory for the test
#
class ProjectTest < Test::Unit::TestCase

  class << self
    def startup
      # make temporary directory
      # see http://ruby-doc.org/stdlib-2.0/libdoc/tmpdir/rdoc/Dir.html#method-c-mktmpdir
      @tempdir = Dir.mktmpdir
    end

    def shutdown
      # remove the directory.
      FileUtils.remove_dir tempdir
    end

    def tempdir
      @tempdir
    end
  end

  def setup
    @project_name = 'project1' if @project_name.nil?
    # copy the project over to the tempdir
    FileUtils.cp_r(project_source_directory, tempdir)
    # change to the project directory to easyly run rake
    @original_cwd = FileUtils.getwd
    FileUtils.chdir(project_directory)
  end

  def teardown
    FileUtils.chdir(@original_cwd)
    FileUtils.remove_dir(project_directory)
  end

  def project_directory
    File.join(tempdir, @project_name)
  end

  def project_source_directory
    File.join(File.dirname(__FILE__), 'projects', @project_name)
  end

  def tempdir
    self.class.tempdir
  end

  # test the project configuration

  def test_tempdir_exists
    assert File.directory?(tempdir)
  end

  def test_there_is_a_rakefile_in_the_project_directory
    assert File.file?(File.join(project_directory, 'Rakefile'))
    assert File.file?(File.join(project_source_directory, 'Rakefile'))
  end

  def test_cwd_is_project_directory
    assert_equal FileUtils.getwd, project_directory
  end

end

class RakeTaskTest < ProjectTest

  def test_transformations_are_listed
    IO.popen("bundle exec rake -T") { |f| 
      puts f.gets 
    }
  end


end




