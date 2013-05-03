require "maglev_record/snapshot/change"

module MaglevRecord
  class ClassSnapshot
    def initialize(cls)
      @cls = cls
      @attr_readers = cls.attr_readers
    end

    def cls
      @cls
    end

    def changes_since(older)
      return nil unless changed_since?(older)
      ClassChange.new(older, self)
    end

    def changed_since?(older)
      attr_readers != older.attr_readers
    end

    def attr_readers
      @attr_readers
    end

    def class_name
      @cls.name
    end
  end

  class Snapshot

    def for_class(cls)
      ClassSnapshot.new(cls)
    end

    def initialize
      @class_snapshots = Snapshotable.snapshotable_classes.map{ |cls|
        for_class cls
      }
    end

    def changes_since(older)
      Change.new(older, self)
    end

    def class_snapshots
      Array.new(@class_snapshots)
    end

  end
end

