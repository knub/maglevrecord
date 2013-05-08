require "migration/test_project.rb"

class AutomigrationProject2 < ProjectTest

  def setup
    Maglev.abort_transaction
    @project_name = 'project2'
    super
    project_model_source("")
    Maglev.persistent do
      Object.remove_const :ProjectModel if defined?(ProjectModel)
    end
    snapshot!
    Maglev.commit_transaction
    @error_message = nil
  end

  def snapshot!
    # define the interface that rake should use
    Maglev::PERSISTENT_ROOT[:last_snapshot] = MaglevRecord::Snapshot.new
  end

  def changes
    MaglevRecord::Snapshot.new.changes_since Maglev::PERSISTENT_ROOT[:last_snapshot]
  end

  def teardown
    super
    puts @error_mesage unless @error_message.nil?
    Maglev.abort_transaction
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
  end

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


