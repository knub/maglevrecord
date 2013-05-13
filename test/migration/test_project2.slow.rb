require "migration/test_project"

class MigrationProject2 < ProjectTest

  def setup
    Maglev.abort_transaction
    @project_name = 'project2'
    super
    Maglev.persistent do
      Object.remove_const :ProjectModel if defined?(ProjectModel)
    end
    Maglev.commit_transaction
    @s = nil
  end

  def teardown
    super
    puts @s unless @s.nil?
    Maglev.abort_transaction
  end

  def test_no_models
    Maglev.abort_transaction
    assert_raise(NameError) {
      ProjectModel
    }
  end

  def test_models_appear
    @s = rails_c("puts ProjectModel\nMaglev.commit_transaction")
    Maglev.abort_transaction
    assert_equal ProjectModel.all, []
    @s = nil
  end

  def test_add_more_migrations_that_will_be_tested
    # maybe we are also in the need to autoload the model files?
    fail('todo')
  end

end
