require "maglev_record/snapshot/change"

module MaglevRecord
  class Snapshot

    def initialize
    end

    def changes_since(older)
      Change.new(self, older)
    end
  end
  Snapshot.maglev_persistable(true)
end

