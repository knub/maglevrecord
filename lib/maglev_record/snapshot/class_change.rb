module MaglevRecord

  #
  # Change of a class between two class snapshots
  #
  class ClassChange
    def initialize(old, new)
      @old = old
      @new = new
    end

    def new_attributes
      (@new.attributes - @old.attributes).sort
    end

    def removed_attributes
      (@old.attributes - @new.attributes).sort
    end

    def class_name
      @old.class_name
    end

    def changed_class
      @old.snapshot_class
    end

    def migration_string_list
      if removed_attributes.size == 1 and new_attributes.size == 1
        from_attr = removed_attributes.first
        to_attr = new_attributes.first
        ["#{class_name}.rename_attribute(:#{from_attr}, :#{to_attr})"]
      else
        removed_attributes.map{ |attr|
          "#{class_name}.delete_attribute(:#{attr})"
        } + new_attributes.map{ |attr|
          "#new accessor :#{attr} of #{class_name}"
        }
      end + new_class_methods.map{ |cm|
          "#new class method: #{class_name}.#{cm.to_s}"
        } + new_instance_methods.map{ |im|
          "#new instance method: #{class_name}.new.#{im.to_s}"
        } + removed_class_methods.map{ |cm|
          "#{class_name}.remove_class_method :#{cm}"
        } + removed_instance_methods.map{ |im|
          "#{class_name}.remove_instance_method :#{im}"
        }
    end

    def new_instance_methods
      (@new.instance_methods - @old.instance_methods).sort
    end

    def removed_instance_methods
      (@old.instance_methods - @new.instance_methods).sort
    end

    def new_class_methods
      (@new.class_methods - @old.class_methods).sort
    end

    def removed_class_methods
      (@old.class_methods - @new.class_methods).sort
    end
  end
end
