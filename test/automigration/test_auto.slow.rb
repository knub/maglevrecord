require "automigration/rake_task_base"

class TestAutomigrationShow < RakeTaskTestBase

  def setup
    super
    @output = nil
  end

  def teardown
    super
    puts @output unless @output.nil?
  end

  def test_auto
    project_model_source("class ProjectModel
                            include MaglevRecord::Base
                            def x; end
                          end")
    @output = rake("migrate:auto")
    assert File.directory? './migrations'
    assert_not_equal [], Dir[File.join(FileUtils.pwd, 'migrations', '*')]
    file_name = Dir['./migrations/*'].first
    assert_include? @output, file_name
    content = File.open(file_name){|f| f.read }
    assert_include? content, "MaglevRecord::Migration.new"
    assert_include? content, "  def up\n    #new class: ProjectModel\n  end"
    @output = nil
  end

  def test_no_changes_no_file
    @output = rake("migrate:auto")
    assert_equal "# no changes\n", @output
    assert_equal [], Dir[File.join(FileUtils.pwd, 'migrations', '*')]
    @output = nil
  end

end
