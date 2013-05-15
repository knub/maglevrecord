require "maglev_record/snapshot/snapshotable"
require "maglev_record/snapshot/class_snapshot"
require "maglev_record/snapshot/change"

module MaglevRecord

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

    def snapshot_classes
      class_snapshots.map(&:snapshot_class)
    end

    def class_names
      class_snapshots.map(&:class_name).sort
    end

    def [](cls)
      class_snapshots.each{ |snap|
        return snap if snap.snapshot_class == cls
      }
    end
  end
end

