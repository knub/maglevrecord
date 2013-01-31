require "maglev_record/rooted_persistence"

require "time"

module MaglevRecord

  class Migration
    include RootedPersistence
    include ::Comparable

    attr_accessor :source
    attr_reader :timestamp
    attr_reader :name

    def initialize(timestamp, name, &block)
      if (timestamp.kind_of? String)
        @timestamp = Time.parse(timestamp)
      else
        @timestamp = timestamp
      end

      @name = name
      @done = false
      instance_eval &block unless block.nil?
    end

    def id
      [timestamp.month, timestamp.day, timestamp.hour, timestamp.min, timestamp.sec].reduce(timestamp.year.to_s) do |sum, s|
        sum + s.to_s.rjust(2, '0')
      end + name.to_s
      # "#{timestamp.year}#{timestamp.month.rjust(2, '0')}#{timestamp.day}#{timestamp.hour}#{timestamp.min}#{timestamp.sec}#{name}"
    end

    def to_s
      "MaglevRecord::Migration<\"#{timestamp.year}-#{timestamp.month}-#{timestamp.day} #{timestamp.hour}:#{timestamp.min}:#{timestamp.sec}\", \"#{name}\">"
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
