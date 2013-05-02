require "maglev_record"
require "migration/operation_setup"
require "more_asserts"
require 'time'



#
# make sure renamed classes can be migrated even if they are not yet existent
#
# 1) imagine a system with out a class A and the following migrations to be applied:
#
#    rename A to B
#    rename B to C
#
# 3) fail silently vs. do not execute
#    chosen: 3.2
#    3.1) Migration touches :ModelClass => not executed if not present
#    3.2) ModelClass contant returns Null Object that can be migrated but does nothing
#

class TestMigrateWithRenamingWorks < Test::Unit::TestCase

  def setup
    Object.module_eval "
    class A 
      include MaglevRecord::RootedBase
    end
    "
  end
  
  def migrations
    [
      MaglevRecord::Migration.new(Time.now, "rename A to B") do
        def up
          rename_class A, :B
        end
      end,
      MaglevRecord::Migration.new(Time.now + 1, "rename B to C") do
        def up
          rename_class B, :C
        end
      end,
      MaglevRecord::Migration.new(Time.now + 2, "rename C to D") do
        def up
          rename_class C, :D
        end
      end
    ].sort
  end
  
  def do_migrations
    migrations.each { |migration|
      migration.do
    }
  end

  def test_can_rename_all_migrations
    class_A = A
    do_migrations
    assert_equal class_A, D
  end

end




