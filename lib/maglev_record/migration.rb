
module MaglevRecord
  Maglev::persistent do

    class Migration

      @@migrations = Hash.new

      def self.first
        @@first = self.with_timestamp("init")
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
        @parent = a_migration
        a_migration._add_child(self) unless a_migration.nil?
        self
      end

      def parent
        @parent
      end
    end

  end

end





