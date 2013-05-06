
module MaglevRecord

  class ClassChange
    def initialize(old, new)
      @old = old
      @new = new
    end
    def new_attr_accessors
      @new.attr_readers - @old.attr_readers
    end
    def removed_attr_accessors
      @old.attr_readers - @new.attr_readers
    end
  end

  class Change

    def initialize(old, new)
      @old = old
      @new = new
    end

    def changed_classes
      changes = []
      @new.class_snapshots.each{ |new|
        @old.class_snapshots.each { |old|
          if  old == new and
              new.changed_since? old
            changes << new.changes_since(old)
          end
        }
      }
      changes
    end

    def removed_classes
      @new.class_snapshots.select{ |new|
        not new.exists? and @old.class_snapshots.all?{ |old|
          old != new
        }
      }
    end

    def new_classes
      @new.class_snapshots.select{ |new|
        new.exists? and @old.class_snapshots.all?{ |old|
          old != new
        }
      }
    end
  end
end
