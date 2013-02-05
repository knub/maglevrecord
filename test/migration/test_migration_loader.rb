require "maglev_record"
require "more_asserts"

class TestMigrationLoader < Test::Unit::TestCase

  def setup
    @loader = MaglevRecord::MigrationLoader.new
  end

  def migration_folder
    File.dirname(__FILE__) + '/migrations'
  end

  def test_load_simple_migration
    assert_equal @loader.migration_list.size, 0
    list = @loader.load_string <<-MIGRATION
Migration.new(Time.utc(2013, 2, 1, 10, 0, 0, 0), "Change book title") do
  def up
    Book.each do |book|
      book.title = "A new book title"
    end
  end
  def down
    Book.each do |book|
      book.title = "Back to old title"
    end
  end
end
MIGRATION
    assert_equal @loader.migration_list.size, 1
    assert @loader.migration_list.any? { |m| m.name == "Change book title" }
  end

  # def test_load_several_migrations
  #   _l1 = l.load_string "
  #     m = migration(#{t1.inspect}).follows(first_migration)
  #     @l = []
  #     m.up{
  #       @l << 2
  #     } unless m.has_up?
  #     m.down{
  #       raise ArgumentError if @l.delete(2).nil?
  #     } unless m.has_down?
  #     @l
  #   "
  #   s = "
  #     @l = []
  #     m = migration(#{t2.inspect}).follows(migration(#{t1.inspect}))
  #     m.up{ @l << 3 } unless m.has_up?
  #     m.down{@l << 6 } unless m.has_down?
  #     @l
  #   "
  #   _l2 = l.load_string s
  #   _l3 = l.load_string s
  #   assert_equal _l1, []
  #   assert_equal _l2, []
  #   assert_equal _l3, []

  #   l.up
  #   assert_equal _l1, [2]
  #   assert_equal _l2, [3]
  #   assert_equal _l3, []

  #   l2 = ML.new
  #   l2.up
  #   assert_equal _l1, []
  #   assert_equal _l2, [3, 6]
  #   assert_equal _l3, []
  # end

  # def test_eval_is_not_in_context_of_loader
  #   l.lalilulalilu
  #   assert_raise(NoMethodError){
  #     l.load_string "lalilulalilu"
  #   }
  # end

  # def test_load_from_file
  #   l.load_file(migration_folder + 'migration_1.rb')
  #   assert l.migrations.any?{|m| m.timestamp.to_s == "2013-01-22 18:31:11 +00:00"}
  # end

  # def test_load_directory
  #   l.load_directory(migration_folder)
  #   assert l.migrations.any?{|m| m.timestamp.to_s == "2013-01-22 18:31:11 +00:00"}
  #   assert l.migrations.any?{|m| m.timestamp.to_s == "2012-01-22 19:01:01 +00:00"}
  # end

  # def test_use_method_of_context_in_up
  #    s = "
  #     m = migration(#{t2.inspect}).follows(migration(#{t1.inspect}))
  #     m.up{ method_used_by_up } unless m.has_up?
  #     m.down{ method_used_by_down } unless m.has_down?
  #   "
  #   l.load_string s
  #   l.up # no error
  #   l2 = ML.new
  #   l2.up # no error
  # end

end
