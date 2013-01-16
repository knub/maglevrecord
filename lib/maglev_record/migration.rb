
module MaglevRecord
  Maglev::persistent do

    class Migration
      include Persistence
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

      end

      # save instances
      # replace with MaglevRecord::Model

      def self.first
        @@first = first = self.with_timestamp(FirstTimestamp.new)
        first.up{} unless first.has_up?
        first.down{} unless first.has_down?
        first
      end

      def self.with_timestamp(timestamp)
        migration = object_pool[timestamp]
        if migration.nil?
          object_pool[timestamp] = migration = self.new(timestamp)
        end
        migration
      end


      def self.size
        object_pool.size
      end

      def initialize(timestamp)
        @timestamp = timestamp
        @children = []
        @parents = []
        @down = nil
        @up = nil
        @done = false
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

      def to_s
        self.class.name + ".with_timestamp(#{timestamp.inspect})"
      end

      def inspect
        to_s
      end
    end

    #
    # A MigrationList contains  a list of migrations 
    # that should be done when the list is the last MigrationList 
    # in the system (MigrationList.last)
    #
    class MigrationList
      include Persistence

      class Migration < MaglevRecord::Migration
      end

      class InconsistentMigrationState < Exception
      end

      class FirstMigrationList
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
      end

      def parent
        @parent
      end

      def migrations
        list = migration_set.to_a
        list.sort
      end

      def migration_set
        todo = Set.new(@migration_set)
        set = Set.new
        while not todo.empty?
          migration = todo[0]
          todo.delete(migration)
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

    end

  end

end





