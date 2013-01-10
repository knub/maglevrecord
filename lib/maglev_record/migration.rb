
module MaglevRecord
  Maglev::persistent do

    #
    # Subclass Migration
    #
    class Migration

      @@migrations = Hash.new

      def self.first
        @@first = self.with_timestamp('')
      end

      def self.now
        Time.now
      end
      
      def self.with_timestamp(timestamp)
        migration = self.new(timestamp)
        @@migrations[timestamp] = migration
        migration
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

      def follows(a_migration)
        @parent = a_migration
        self
      end

      def parent
        @parent
      end
    end

  end

end





