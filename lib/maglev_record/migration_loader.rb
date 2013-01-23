require "set"
require "maglev_record/migration"
require "maglev_record/migration_context"
require "maglev_record/migration_set"

module MaglevRecord
  #
  # A MigrationList contains a migrations
  # Those migrations can be done with up
  # up rolls back every migration that is not in the list but
  # found in list::Migration.all
  #
  class MigrationLoader
    include RootedPersistence

    class Migration < MaglevRecord::Migration
    end

    class InconsistentMigrationState < Exception
    end

    def initialize
      @migration_set = MigrationSet.new
    end

    def migration_set
      @migration_set.copy
    end

    def migration(timestamp)
      migration = Migration.with_timestamp(timestamp)
      @migration_set << migration
      migration
    end

    def first_migration
      fm = Migration.first
      @migration_set.add fm
      fm
    end

    def up
      consistent_raise
      todo = migrations_to_do
      undo = migrations_to_undo
      undo.each{ |migration|
        migration.undo
      }
      todo.each{ |migration|
        migration.do
      }
    end

    def consistent?
      begin
        consistent_raise
        return true
      rescue InconsistentMigrationState
        return false
      end
    end

    def consistent_raise
      #raise InconsistentMigrationState, "This list must include #{first_migration}" unless migration_set.include? first_migration
      raise InconsistentMigrationState, "This list has circular references: #{migration_set.circles}" if migration_set.has_circle?
      migration_set.expanded.each { |migration|
        if not migration.done?
          migration.children.each{ |child|
            raise InconsistentMigrationState, "#{child} is done but depends on undone migration #{migration}" if child.done?
          }
        end
      }
    end

    def load_string(string)
      migration_context.load_string(string)
    end

    def load_file(string)
      migration_context.load_file(string)
    end

    def load_directory(string)
      migration_context.load_directory(string)
    end

    def migration_context
      MigrationContext.new(self)
    end

    def migrations
      migration_set.expanded.migrations_by_time
    end

    def migrations_to_undo
      skip = migration_set.expanded_parents.migration_sequence
      skip = Migration.select{ |migration|
        ! skip.include?(migration) and migration.done?
      }
      skip.reverse
    end

    def migrations_to_do
      todo = migration_set.expanded_parents
      todo = MigrationSet.new(todo)
      todo = todo.migration_sequence
      todo = todo.select{ |migration| ! migration.done? }
      todo
    end

    def migrations_to_skip
      skip  = Set.new(Migration.all) - Set.new(migrations_to_do) 
      skip -= Set.new(migrations_to_undo)
      MigrationSet.new(skip).migrations_by_time
    end

  end
end
