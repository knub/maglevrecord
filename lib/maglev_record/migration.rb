
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
        @parent = nil
        @down = nil
        @up = nil
        @done = false
      end

      # linked tree of migrations

      def children
        @children
      end

      def _add_child(a_migration)
        @children << a_migration
      end

      def follows(a_migration)
        raise ArgumentError, "#{a_migration} must have timestamp before mine #{@timestamp} to be my parent" if a_migration.timestamp >= timestamp
        raise ArgumentError, "can only follow one migration" unless @parent.nil? or @parent == a_migration
        @parent = a_migration
        a_migration._add_child(self)
        self
      end

      def parent
        @parent
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

    class MigrationList
      include Persistence

      class Migration < MaglevRecord::Migration
      end

      class InconsistentMigrationState < Exception
      end

      def self.last
        object_pool[:last]
      end

      def self.new
        object = super
        object_pool[:last] = object
      end

      def initialize
        @parent = self.class.last
        @migrations = []
      end

      def migration(timestamp)
        migration = Migration.with_timestamp(timestamp)
        @migrations << migration
        migration
      end

      def first_migration
        Migration.first
      end

      def last_migration
        first_migration
      end

      def up

      end

      def consistent?
        migrations.include? first_migration
      end

      def parent
        @parent
      end

      def migrations
        list = []
        @migrations.each{ |migration|
          while not list.include? migration and not migration.nil?
            list << migration
            migration = migration.parent
          end
        }
        list.sort
      end

    end

  end

end





