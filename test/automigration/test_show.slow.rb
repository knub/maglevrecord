require "automigration/rake_task_base"

class TestAutomigrationShow < RakeTaskTestBase

  def test_automigrate_has_no_output_if_no_changes
    rake_output = rake("migrate:auto?")
    assert_equal "# no changes\n", rake_output
  end

  def test_project_model_is_new
    project_model_source("class ProjectModel
                            include MaglevRecord::Base
                            def x; end
                          end")
    rake_output = rake("migrate:auto?")
    assert_equal "#new class: ProjectModel\n", rake_output
  end

end


