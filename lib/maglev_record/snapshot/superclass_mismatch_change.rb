module MaglevRecord
  class SuperclassMismatchChange
    "new_class_names new_classes
    removed_class_names removed_classes changed_classes changed_class_names
    ".split.each do |name|
      define_method(name){ [] }
    end

    def initialize(cls, file_path)
      @cls = cls
      @file_path = file_path
    end

    def nothing_changed?
      false
    end

    def migration_string(identation = 0)
      " " * identation + ["# TypeError: superclass mismatch for #{class_name}",
       "# in #{@file_path}",
       "#{class_name}.remove_superclass"].join("\n" + " " * identation)
    end

    def superclass_mismatch_classes
      [self]
    end

    def superclass_mismatch_class_names
      superclass_mismatch_classes.map(&:class_name)
    end

    # methods for the single change

    def class_name
      mismatching_class.name
    end

    def mismatching_class
      @cls
    end

    def changes_since(snapshot)
      self
    end
  end
end
