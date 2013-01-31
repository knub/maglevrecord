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
      instance_eval &block unless block.nil?
    end

    def id
      # TODO: Use better to string function for timestamp
      @timestamp.to_s + @name
    end

    # e.g. "2013-01-05 12:20:20 migration"
    def to_s
      "#{timestamp.year}-#{timestamp.month}-#{timestamp.day} #{timestamp.hour}:#{timestamp.min}:#{timestamp.sec} #{name}"
    end

    def inspect
      source
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
