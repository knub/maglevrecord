require "maglev_record/snapshot/class_change.rb"

module MaglevRecord

  class ClassSnapshot
    def initialize(cls)
      cls.redo_include_and_extend
      @snapshot_class = cls
      @attributes = cls.snapshot_attributes if cls.respond_to? :snapshot_attributes
      @files = cls.file_paths
      @exists = cls.has_definitions?
      @class_methods = cls.snapshot_class_methods
      @instance_methods = cls.snapshot_instance_methods
    end

    def exists?
      @exists
    end

    def ==(other)
          self.snapshot_class == other.snapshot_class \
      and self.exists? == other.exists?
    end

    alias :eql? :==

    def <=>(other)
      class_name <=> other.class_name
    end

    def snapshot_class
      @snapshot_class
    end

    def changes_since(older)
      return nil unless changed_since?(older)
      ClassChange.new(older, self)
    end

    def changed_since?(older)
      attributes != older.attributes or
        instance_methods != older.instance_methods or
        class_methods != older.class_methods
    end

    def attributes
      Array.new(@attributes || []).sort.uniq
    end

    def class_name
      @snapshot_class.name
    end

    def class_methods
      Array.new(@class_methods)
    end

    def instance_methods
      @instance_methods
    end
  end
end

