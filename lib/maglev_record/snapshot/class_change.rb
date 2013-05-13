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

    def class_name
      @old.class_name
    end

    def migration_string
      if removed_attr_accessors.size == 1 and new_attr_accessors.size == 1
        from_attr = removed_attr_accessors.first
        to_attr = new_attr_accessors.first
        ["#{class_name}.rename_attribute(:#{from_attr}, :#{to_attr})"]
      else
        removed_attr_accessors.map{ |attr|
          "#{class_name}.delete_attribute(:#{attr.to_s})"
        } + new_attr_accessors.map{ |attr|
          "#new accessor :#{attr} of #{class_name}"
        }
      end.join("\n")
    end
  end
end
