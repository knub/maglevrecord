require "migration/test_project"

class MigrationProject2 < ProjectTest

  def setup
    @project_name = 'project2'
    super
    Maglev.persistent do
      Object.remove_const :ProjectModel if defined?(ProjectModel)
    end
    Maglev.commit_transaction
  end

  def test_no_models
    Maglev.abort_transaction
    assert_raise(NameError) {
      ProjectModel
    }
  end

  def test_models_appear
    s = rails_c("puts ProjectModel\nMaglev.commit_transaction")
    Maglev.abort_transaction
    assert_equal ProjectModel.all, []
  end

end
