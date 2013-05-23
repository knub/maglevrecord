
module MaglevRecord

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

    def changed_class_names
      changed_classes.map(&:class_name).sort
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

    def new_class_names
      new_classes.map(&:class_name).sort
    end

    def migration_string_list
      if removed_classes.size == 1 and new_classes.size == 1
        ["rename_class #{removed_class_names.first
                  }, :#{new_class_names.first}"]
      else
        removed_class_names.map{ |class_name|
          "delete_class #{class_name}"
        } + new_class_names.map{ |class_name|
          "#new class: #{class_name}"
        }
      end + changed_classes.map(&:migration_string_list).flatten
    end

    def migration_string(identation = 0)
      " " * identation + migration_string_list.select{ |s| s.strip != ""}.join("\n" + " " * identation)
    end

    def nothing_changed?
      removed_classes == [] and changed_classes == [] and new_classes == []
    end

    def [](class_or_class_name)
      changed_classes.each{ |change|
        return change if change.changed_class == class_or_class_name or
                         change.class_name == class_or_class_name
      }
    end

    def superclass_mismatch_classes
      []
    end

  end
end
