
module MaglevRecord

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

  Change.maglev_persistable(true)

end
