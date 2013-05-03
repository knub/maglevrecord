require "maglev_record/snapshot/change"

module MaglevRecord
  class ClassSnapshot
    def initialize(cls)
      @cls = cls
    end
    def cls
      @cls
    end
    def ==(other)
      other.cls == cls
    end
    def class_name
      @cls.name
    end
    def class
      @cls
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

