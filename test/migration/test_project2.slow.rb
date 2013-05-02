require "migration/test_project"

class MigrationProject2 < ProjectTest

  def setup
    @project_name = 'project2'
    super
    Object.remove_const :TestModel if defined?(TestModel)
    Maglev.commit_transaction
  end

  def test_no_models
    Maglev.abort_transaction
    assert_raise(NameError) {
      TestModel
    }
  end

  def test_models_appear
    s = rails_c("puts TestModel\nMaglev.commit_transaction")
    p s
    Maglev.abort_transaction
    assert_equal TestModel.all, []
  end

end
