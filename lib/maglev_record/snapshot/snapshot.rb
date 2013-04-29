require "maglev_record/snapshot/change"

module MaglevRecord
  class ClassSnapshot
    def initialize(cls)
      @name = cls.name
      @cls = cls
    end
  end

  class Snapshot

    def for_class(cls)
      ClassSnapshot.new(cls)
    end

    def initialize
      @classes = Snapshot.snapshotable_classes.map{ |cls|
        for_class cls
      }
    end

    def changes_since(older)
      Change.new(self, older)
    end

  end
end

