
module MaglevRecord

  class Change

    def initialize(old, new)
      @old = old
      @new = new
    end

    def changed_classes
      []
    end

    def removed_classes
      @old.classes - @new.classes
    end

    def new_classes
      @new.classes - @old.classes
    end
  end
end
