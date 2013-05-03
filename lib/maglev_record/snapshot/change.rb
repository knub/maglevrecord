
module MaglevRecord

  class Change

    class NewClass
      def initialize(cls)
        @cls = cls
      end
    end

    def initialize(old, new)
      @old = old
      @new = new
    end

    def changed_classes
      []
    end

    def removed_classes
      []
    end

    def new_classes
      @new.class_snapshots - @old.class_snapshots
    end
  end
end
