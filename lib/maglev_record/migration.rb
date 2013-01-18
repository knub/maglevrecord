
require "set"

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
        v = - (t2 <=> t1)
      end
      raise TypeError, "value of <=> should be 1, -1 or 0, not #{v.inspect}" if v != 0 and v != 1 and v != -1
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
  class MigrationList
    include RootedPersistence

    class Migration < MaglevRecord::Migration
    end

    class InconsistentMigrationState < Exception
    end

    class CircularMigrationOrderError < Exception
    end

    class FirstMigrationList
      def delete
      end
      def parents
        []
      end
      def migration_set_done
        Set.new
      end
    end

    def self.first
      object_pool.fetch(:first) {
        object_pool[:first] = FirstMigrationList.new
      }
    end

    def self.last
      object_pool.fetch(:last) {
        object_pool[:last] = first
      }
    end

    def self.new
      object = super
      object_pool[:last] = object
    end

    def initialize
      @parent = self.class.last
      @migration_set = Set.new
    end

    def migration(timestamp)
      migration = Migration.with_timestamp(timestamp)
      @migration_set << migration
      migration
    end

    def first_migration
      Migration.first
    end

    def last_migration
      first_migration
    end

    def up
      raise InconsistentMigrationState, 'this migration is not consistent' unless consistent?
      migrations_to_undo.each{ |migration|
        migration.undo
      }
      migrations_to_do.each{ |migration|
        migration.do
      }
    end

    def consistent?
      mig = migrations
      return false unless mig.include? first_migration
      last_mig = mig[0]
      mig.each { |newer_mig|
        return false if (not last_mig.done? and newer_mig.done?)
        last_mig = newer_mig
      }
      return false if has_circle?
      true
    end

    def parent
      @parent
    end

    #
    # migrations in order of time
    #
    def migrations
      list = migration_set.to_a
      list.sort
    end

    def migration_set
      todo = Set.new(@migration_set)
      set = Set.new
      while not todo.empty?
        migration = todo.pop
        set << migration
        migration.parents.each{ |parent| 
          todo.add(parent) unless set.include? parent
        }
      end
      set
    end

    def migrations_to_do
      (migration_set - migration_set_done).to_a.sort
    end

    def migrations_done
      migration_set_done.to_a.sort
    end

    def migration_set_done
       Set.new(migration_set.select{|migration| migration.done?})
    end

    def migrations_to_undo
      (parent.migration_set_done - migration_set).to_a.sort
    end

    #
    # migrations in order of do and undo
    #
    def migration_order
      raise CircularMigrationOrderError, 'list has circle of migrations' if has_circle?
      mig = migrations
      changed = true
      while changed
        changed = false
        mig.each_index{ |migration_index|
          migration = mig.at(migration_index)
          migration.parents.each{ |parent|
            parent_index = mig.index(parent)
            if parent_index > migration_index
              mig.delete_at(migration_index)
              mig.insert(parent_index, migration)
              migration_index = parent_index
              changed = true
            end
          }
        }
        puts "changed #{changed}"
      end
      mig
    end

    def heads
      migrations.select{ |migration| migration.children.empty? }
    end

    def has_circle?
      not circles.empty?
    end

    def clusters
      s = migration_set
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

    def load_source(string)
      
    end

    def add(migration)
      @migration_set.add(migration)
    end

  end

end





