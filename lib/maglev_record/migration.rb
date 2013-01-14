
module MaglevRecord
  Maglev::persistent do

    class Migration

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

      class Application
        def initialize
          @locked = false if @locked.nil?
          @actions = []
        end

        def do
          @actions << Proc.new unless locked?
        end
        def execute
          lock
          @actions.each { |action|
            action.call
          }
        end
        def lock
          @locked = true
        end
        def locked?
          @locked
        end
      end

      @@migrations = Hash.new

      def self.first
        @@first = self.with_timestamp(FirstTimestamp.new)
      end

      def self.now
        Time.now
      end

      def self.with_timestamp(timestamp)
        if @@migrations[timestamp] == nil
          migration = self.new(timestamp)
          @@migrations[timestamp] = migration
          return migration
        end

        @@migrations[timestamp]
      end

      def self.clear
        @@migrations.clear
      end

      def self.size
        @@migrations.size
      end

      def initialize(timestamp)
        @timestamp = timestamp
        @children = []
        @parent = nil
      end

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

      def timestamp
        @timestamp
      end

      def <=> (other_migration)
        timestamp <=> other_migration.timestamp
      end
    end

  end

end





