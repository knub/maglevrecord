
require "set"
require "maglev_record/rooted_persistence"

class Set
  
  # remove a random element from the set and return it
  #
  def pop
    each{ |element|
      delete element
      return element
    }
  end
end

module MaglevRecord
  
  class Migration
    include RootedPersistence
    include ::Comparable
    # nested classes 

    class DownError < Exception
    end

    class UpError < Exception
    end

    class FirstTimestamp
      include Comparable

      def <=> (other)
        if self.class == other.class
          return 0
        end
        return -1
      end

      def hash
        self.class.hash
      end

      def inspect
        "first"
      end

    end

    # save instances
    # replace with MaglevRecord::Model

    def self.first
      first = self.with_timestamp(FirstTimestamp.new)
      first.up{} unless first.has_up?
      first.down{} unless first.has_down?
      first
    end

    def self.new(timestamp)
      migration = self.object_pool[timestamp]
      return migration unless migration.nil?
      migration = super(timestamp)
      raise NameError, 'timestamp of migration must be object_id' unless migration.object_id == timestamp
      migration
    end

    def self.with_timestamp(timestamp)
      self.new(timestamp)
    end

    def initialize(timestamp)
      @timestamp = timestamp
      @children = []
      @parents = []
      @down = nil
      @up = nil
      @done = false
    end

    def object_id
      timestamp
    end

    # linked tree of migrations

    def children
      @children
    end

    def add_child(a_migration)
      raise ArgumentError, "I can not follow myself" if a_migration.timestamp == timestamp
      @children << a_migration unless @children.include? a_migration
      a_migration.follows(self) unless a_migration.parents.include? self
      self
    end

    def follows(a_migration)
      raise ArgumentError, "I can not follow myself" if a_migration.timestamp == timestamp
      @parents << a_migration unless @parents.include? a_migration
      a_migration.add_child(self)
      self
    end

    alias :add_parent :follows

    def parents
      @parents
    end

    # timestamp 

    def timestamp
      @timestamp
    end

    def <=> (other_migration)
      t1 = timestamp
      t2 = other_migration.timestamp
      v = t1 <=> t2
      if v.nil?
        v = t2 <=> t1
        raise TypeError, "value of <=> should be 1, -1 or 0, not #{v.inspect}. #{t2.inspect} <=> #{t1.inspect}" if v != 0 and v != 1 and v != -1
        v = - v
      end
      return v
    end
    
    def self.now
      Time.now
    end

    # methods for code execution
    
    def up
      raise ArgumentError, 'I can only have one block to execute' unless @up.nil?
      @up = Proc.new
      self
    end

    def down
      raise ArgumentError, 'I can only have one block to execute' unless @down.nil?
      @down = Proc.new
      self
    end

    def done?
      @done
    end

    def do
      raise UpError, 'I am already up' if done?
      @done = true
      @up.call unless @up.nil?
    end

    def undo
      raise DownError, 'I am already down' if not done?
      @done = false
      @down.call unless @down.nil?
    end

    def has_up?
      not @up.nil?
    end

    def has_down?
      not @down.nil?
    end

    def first?
      self.class.first == self
    end

    def to_s
      return self.class.name + ".first" if self.first?
      self.class.name + ".with_timestamp(#{timestamp.inspect})"
    end

    def inspect
      s = self.class.name + " " + timestamp.inspect
      s += " done" if done?
      "<#{s}>"
    end

  end

  #
  # A MigrationList contains  a list of migrations 
  # that should be done when the list is the last MigrationList 
  # in the system (MigrationList.last)
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

    def load_source(string)
      
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

  class MigrationSet
    include ::Enumerable

    class CircularMigrationOrderError < Exception
    end

    def initialize(migrations = Set.new)
      @migrations = Set.new(migrations)
    end

    def migrations
      Set.new(@migrations)
    end

    def expand!(children = true)
      todo = migrations
      while not todo.empty?
        migration = todo.pop
        add migration
        to_expand = migration.parents
        to_expand += migration.children if children
        to_expand.each{ |migration|
          todo.add(migration) unless include? migration
        }
      end
      self
    end

    def expand_parents!
      expand!(children = false)
    end

    def copy
      self.class.new(self)
    end

    def expanded
      self.copy.expand!
    end

    def expanded_parents
      self.copy.expand_parents!
    end

    alias :dup :copy

    #
    # migrations in order of do and undo
    #
    def migration_sequence
      raise CircularMigrationOrderError, 'list has circle of migrations' if has_circle?
      # use tsort? 
      # http://www.ruby-doc.org/stdlib-1.9.3/libdoc/tsort/rdoc/TSort.html
      todo = tails.to_a
      result = []
      while not todo.empty?
        todo.sort!
        migration_to_expand = todo.delete_at(0)
        result << migration_to_expand
        migration_to_expand.children.each{ |child|
          todo << child unless (todo.include? child or !include? child)
          result.delete(child)
        }
      end
      result
    end

    def migrations_by_time
      migrations.to_a.sort
    end

    def heads
      Set.new(migrations.select{ |migration| 
        migration.children.all?{ |child|
            ! include?(child)
          }
        })
    end

    # return a set of migrations without parent
    def tails
      Set.new(migrations.select{ |migration| 
        migration.parents.all?{ |parent|
            ! include?(parent)
          }
        })
    end

    def has_circle?
      not circles.empty?
    end

    def clusters
      s = migrations
      clusters = Set.new
      while not s.empty?
        todo = Set.new([s.pop])
        cluster = Set.new
        while not todo.empty?
          m = todo.pop
          s.delete(m)
          cluster.add(m)
          (m.parents + m.children).select{ |migration|
            s.include? migration
          }.each{ |migration|
            todo.add(migration)
          }
        end
        clusters.add(cluster.to_a.sort)
      end
      clusters
    end

    def circles
      circles = Set.new
      clusters.each{ |cluster| 
        while not cluster.empty?
          leaf_found = cluster.any?{ |migration|
            no_parents = !migration.parents.any?{|parent| cluster.include? parent}
            no_children = !migration.children.any?{|child| cluster.include? child}
            leaf_found = (no_children or no_parents)
            if leaf_found
              cluster.delete(migration)
            end
            leaf_found
          }
          break if not leaf_found
        end
        circles.add(cluster) unless cluster.empty?
      }
      circles
    end

    def add(migration)
      @migrations.add(migration)
    end

    alias :<< :add

    def include?(migration)
      @migrations.include?(migration)
    end

    def empty?
      @migrations.empty?
    end

    def each
      raise ArgumentError, 'I need a block argument for iteration ' unless block_given?
      migrations.each{ |migration| yield migration}
    end

  end

end





