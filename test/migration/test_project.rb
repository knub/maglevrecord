require "more_asserts"
require "fileutils"
require "temp_dir_test"

THIS_DIRECTORY = File.expand_path(File.dirname(__FILE__))

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
    File.join(THIS_DIRECTORY, 'projects', @project_name)
  end

  def test_there_is_a_rakefile_in_the_project_directory
    assert File.file?(File.join(project_directory, 'Rakefile'))
    assert File.file?(File.join(project_source_directory, 'Rakefile'))
  end

  def test_cwd_is_project_directory
    assert_equal FileUtils.getwd, project_directory
  end

  #
  # rake returns the output of the process so one can print it
  #
  def rake(args)
    exec("bundle exec rake " + args)
  end

  def rails_c(commands)
    # add the path where maglev_record can be found
    commands = "$LOAD_PATH.unshift './maglevrecordgem'\n" +
               "$LOAD_PATH.unshift './maglevrecordgem/lib'\n" +
               commands +
               "\nexit\n"
    exec('bundle exec rails c', commands)
  end

  def exec(_command, input = '')
    File.open('input.txt', 'w') {|f| f.write(input) }
    command = "export MAGLEV_OPTS=\"-W0 --stone #{
                    Maglev::System.stone_name}\";#{
                    _command} < input.txt"
    output = IO.popen(command) { |f|
      s = line = ''
      while not line.nil?
        s += line
        line = f.gets
      end
      output = s
    }
    # p output
    output
  end
end

