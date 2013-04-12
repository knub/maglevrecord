require "time"

module MaglevRecord
  ##
  # This class represents a migration which transfers the data set from one
  # state to another.
  # Each migrations is identified by its name and its timestamp. Creating a new
  # migration is as easy as:

  #   Migration.new("2013-02-02 1, 10, 0, 0, 0), "Change book title") do
  #     def up
  #       Book.each do |book|
  #         book.title = "A new book title"
  #       end
  #     end
  #     def down
  #       Book.each do |book|
  #         book.title = "Back to old title"
  #       end
  #     end
  #   end
  # Furthermore, this class offers methods to actually do data migration.
  class Migration
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
      self.class.id_for(timestamp, name)
    end

    def hash
      id.hash
    end

    def self.id_for(timestamp, name)
      [timestamp.month, timestamp.day, timestamp.hour, timestamp.min, timestamp.sec].reduce(timestamp.year.to_s) do |sum, s|
        sum + s.to_s.rjust(2, '0')
      end + name.to_s
    end

    def to_s
      self.class.name + "<\"#{timestamp.year}-#{timestamp.month.to_s.rjust(2, '0')}-#{timestamp.day.to_s.rjust(2, '0')} #{timestamp.hour.to_s.rjust(2, '0')}:#{timestamp.min.to_s.rjust(2, '0')}:#{timestamp.sec.to_s.rjust(2, '0')}\", \"#{name}\">"
    end

    def inspect
      source
    end

    def self.new(timestamp, name)
      timestamp = Time.parse(timestamp) if timestamp.kind_of? String
      id = id_for(timestamp, name)
      migration = super(timestamp, name)
    end

    def done?
      @done
    end

    def do
      up if respond_to?(:up) && !done?
      @done = true
    end

    def undo
      down if done?
      @done = false
    end

    def down
      raise IrreversibleMigration, "The migration has no down code specified. Do something about it man. Either give it up or write a down method into the migration definition."
    end

    def <=>(other)
      compare = timestamp <=> other.timestamp
      return compare if compare != 0
      name <=> other.name
    end

    def rename_class(old_class, new_name)
      old_name = old_class.name
      Maglev.persistent do
        cls = Object.remove_const old_name
      end
      old_class.instance_eval "
        def name
          '#{new_name.to_s}'
        end
      "
      Object.const_set new_name, old_class
    end

    def delete_class(cls)
      Maglev.persistent do
        Object.remove_const(cls.name.to_sym)
      end
    end

    def self.const_missing(name)
      return MigrationOperations::NullClass.new(name)
    end
  end
end
