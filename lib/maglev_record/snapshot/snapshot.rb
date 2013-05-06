require "maglev_record/snapshot/change"

module MaglevRecord
  class ClassSnapshot
    def initialize(cls)
      @snapshot_class = cls
      @attr_readers = cls.attr_readers if cls.respond_to? :attr_readers
      @files = cls.file_paths
      @exists = cls.has_definitions?
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
      attr_readers != older.attr_readers
    end

    def attr_readers
      @attr_readers || []
    end

    def class_name
      @snapshot_class.name
    end
  end

  class Snapshot

    def for_class(cls)
      ClassSnapshot.new(cls)
    end

    def initialize(classes = Snapshotable.snapshotable_classes)
      @class_snapshots = classes.map{ |cls|
        for_class cls
      }
    end

    def changes_since(older)
      Change.new(older, self)
    end

    def class_snapshots
      Array.new(@class_snapshots)
    end

    def class_names
      class_snapshots.map(&:class_name).sort
    end

  end
end

