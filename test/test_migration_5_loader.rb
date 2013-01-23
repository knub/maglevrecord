require "test_migration_loader_base"

class TestMigrationList_load_migrations < TestMigrationLoaderBase
  
  # TODO pending

  def test_load_simple_migration
    h = l.load_source "
      l = []
      m = migration(1).follows(first_migration)
      m.up{ l << 1 } unless m.has_up?
      m.down{ assert l.delete(1) == 1 } unless m.has_down?
      l
    "
    list = h["l"]
    m = h["m"]
    assert m.is_migration?
    assert ! list.is_migration?
    assert_equal list, []
    assert l.migration_set.include? m
  end

  def test_load_several_migrations
    h1 = l.load_source "
      # TODO: discuss this, could be unliked
      migration(2).follows(first_migration)
      l = []
      migration.up{
        l << 2
      } unless migration.has_up?
      migration.down{
        if unless l.delete(2).nil?
      } unless migration.has_down?
      l
    "
    s = "
      l = []
      m = migration(3).follows(migration(2))
      m.up{ l << 3
      } unless m.has_up?
      m.down{l << 6} unless m.has_down?
      l
    "
    h2 = l.load_source s
    h3 = l.load_source s
    l.up
    assert_equal h1["l"], [2]
    assert_equal h2["l"], [3]
    assert_equal h3["l"], []
    assert l.migration(2).done?
    l2 = ML.new
    l2.up
    assert_equal h1["l"], []
    assert_equal h2["l"], [3, 6]
    assert_equal h3["l"], []
    assert ! l.migration(2).done?
  end

  def test_eval_is_not_in_context_of_loader
    l.lalilulalilu
    assert_raise(NoMethodError){
      l.load_source "lalilulalilu"
    }
  end

end
