
module MaglevRecord
  class Snapshot
    def changes_since(older)
      Change.new(self, older)
    end
    class Change
      def changed_classes
        []
      end
      def removed_classes
        []
      end
      def new_classes
        []
      end
    end
  end
  Snapshot.maglev_persistable(true)
  Snapshot::Change.maglev_persistable(true)
end


