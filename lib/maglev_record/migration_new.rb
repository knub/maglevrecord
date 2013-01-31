require "maglev_record/rooted_persistence"

module MaglevRecord

  class Migration
    include RootedPersistence
    include ::Comparable

    attr_accessor :source
    attr_reader :timestamp
    attr_reader :name

    def initialize(timestamp, name, &block)
      @timestamp = timestamp
      @name = name
      @done = false
      instance_eval &block
    end

    def id
      # TODO: Use better to string function for timestamp
      @timestamp.to_s + "_" + @name
    end

    def self.new(timestamp, name)
      migration = super(timestamp, name)
      self.object_pool.fetch(migration.id) {
        self.object_pool[migration.id] = migration
        migration
      }
    end

    def done?
      @done
    end

    def do
      puts "does not know up" unless respond_to?(:up)
      up if respond_to?(:up) && !done?
      @done = true
    end

    def undo
      down if respond_to?(:down) && done?
      @done = false
    end

    def <=>(other)
      compare = timestamp <=> other.timestamp
      return compare if compare != 0
      name <=> other.name
    end

    def remove_field
      puts "Removing a field"
    end

  end
end
