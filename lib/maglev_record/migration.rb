
require "maglev_record/rooted_persistence"

class Object
  def is_first_timestamp?
    false
  end
end

module MaglevRecord
  
  class Migration
    include RootedPersistence
    include ::Comparable
    # nested classes 

    class DownError < Exception
    end

    class UpError < Exception
    end

    class FirstTimestamp
      include Comparable

      def <=> (other)
        if other.is_first_timestamp?
          return 0
        end
        return -1
      end

      def hash
        self.class.hash
      end

      def inspect
        "first"
      end

      def timestamp
        self
      end

      def is_first_timestamp?
        true
      end

    end

    # save instances
    # replace with MaglevRecord::Model

    def self.first
      first = self.with_timestamp(FirstTimestamp.new)
      first.up{} unless first.has_up?
      first.down{} unless first.has_down?
      first
    end

    def self.new(timestamp)
      migration = self.object_pool[timestamp]
      return migration unless migration.nil?
      migration = super(timestamp)
      raise NameError, 'timestamp of migration must be id' unless migration.id == timestamp
      migration
    end

    def self.with_timestamp(timestamp)
      self.new(timestamp)
    end

    def initialize(timestamp)
      @timestamp = timestamp
      @children = []
      @parents = []
      @down = nil
      @up = nil
      @done = false
    end

    def id
      timestamp
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

    alias :add_parent :follows

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
        v = t2 <=> t1
        raise TypeError, "value of <=> should be 1, -1 or 0, not #{v.inspect}. #{t2.inspect} <=> #{t1.inspect}" if v != 0 and v != 1 and v != -1
        return - v
      end
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

    def first?
      self.class.first == self
    end

    def to_s
      return self.class.name + ".first" if self.first?
      self.class.name + ".with_timestamp(#{timestamp.inspect})"
    end

    def inspect
      s = self.class.name + " " + timestamp.inspect
      s += " done" if done?
      "<#{s}>"
    end

    # required methods for user interface

    attr_accessor :source
  end
end
