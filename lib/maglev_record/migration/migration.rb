require "time"

class ::String
  def escape_single_quotes
    self.gsub(/[']/, '\\\\\'')
  end
end

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

    attr_accessor :source, :logger
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
      return source unless source.nil?
      to_s
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
      old_class.migration_rename_to(new_name)
    end

    def delete_class(cls)
      cls.migration_delete
    end

    def self.const_missing(name)
      #logger.warn("class #{name} was not created but migration by migration #{self.id}") if logger
      MigrationOperations::NullClass.new(name)
    end

    def self.file_content(time, description, upcode = nil,
                                    downcode = nil)
      timestamp = time.to_s
      Time.parse(timestamp) # make sure there is no error in the string
      upcode = "    # put your transformation code here" if upcode.nil?
      if downcode.nil?
        downcode = "    # put the code that reverses the code in up here \n" +
                   "    # remove the next line that throws he error \n" +
                   "    raise IrreversibleMigration, " +
                                             "'The migration has no downcode'"
      end
      <<-eos
require "maglev_record/migration"
require "time"

MaglevRecord::Migration.new(Time.parse('#{
                          timestamp.escape_single_quotes}'), '#{
                          description.escape_single_quotes}') do

  def up
#{upcode}
  end

  def down
#{downcode}
  end

end
      eos
    end
  end
end
