
module MaglevRecord

  #
  # Change of a class between two class snapshots
  #
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

  #
  # The Change between two snapshots of the image
  #
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
      @old.class_snapshots.select{ |old|
        old.exists? and @new.class_snapshots.all?{ |new|
          old != new
        }
      }
    end

    def removed_class_names
      removed_classes.map(&:class_name).sort
    end

    def new_classes
      @new.class_snapshots.select{ |new|
        new.exists? and @old.class_snapshots.all?{ |old|
          old != new
        }
      }
    end

    def migration_string
      removed_classes.sort.map{ |class_snapshot|
        "delete_class #{class_snapshot.class_name}"
      }.join("\n")
    end

  end
end
