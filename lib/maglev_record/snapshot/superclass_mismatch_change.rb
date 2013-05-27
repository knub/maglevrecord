
class ClassWithMismatchNotFound
  def name
    "<fill in the name of the new superclass here>"
  end
end

module MaglevRecord
  class SuperclassMismatchChangeBase
    "new_class_names new_classes
    removed_class_names removed_classes changed_classes changed_class_names
    ".split.each do |name|
      define_method(name){ [] }
    end

    def nothing_changed?
      false
    end

    def superclass_mismatch_classes
      [self]
    end

    def superclass_mismatch_class_names
      superclass_mismatch_classes.map(&:class_name)
    end

    def changes_since(snapshot)
      self
    end

  end

  class SuperclassMismatchChange < SuperclassMismatchChangeBase
    def initialize(cls, file_path)
      @cls = cls
      @file_path = file_path
    end

    def file_path
      @file_path
    end

    def migration_string(identation = 0)
      " " * identation + [
        "# TypeError: superclass mismatch for #{class_name}",
        "# in #{file_path}",
        "#{class_name}.change_superclass_to #{new_superclass.name}"
      ].join("\n" + " " * identation)
    end

    def determine_new_superclass
      # 1. replace the actual class by a new one
      # 2. inherit
      # 3. get the superclass
      # 4. restore the class
      constant_name = mismatching_class.name
      class_to_replace = nil # change the scope
      Maglev.persistent do
        begin
          class_to_replace = Object.remove_const constant_name
        rescue NameError
          # negative path 1 TODO: test
          return ClassWithMismatchNotFound.new
        else
          if class_to_replace != mismatching_class
            # negative path 2 TODO: test
            Object.const_set constant_name, class_to_replace
            return ClassWithMismatchNotFound.new
          end
        end
      end
      begin
        Kernel.load file_path
        cls = Object.const_get constant_name
        return cls.superclass
      ensure
        Object.const_set constant_name, class_to_replace
      end
    end

    def new_superclass
      @new_super_class = determine_new_superclass if @new_super_class.nil?
      @new_super_class
    end

    # methods for the single change

    def class_name
      mismatching_class.name
    end

    def mismatching_class
      @cls
    end

    # reverse

    def reversed
      ReversedSuperclassMismatchChange.new(self)
    end
  end

  class ReversedSuperclassMismatchChange < SuperclassMismatchChangeBase
    # TODO: test
    def initialize(superclass_mismatch_change)
      @superclass_mismatch_change = superclass_mismatch_change
    end

    def superclass_mismatch_change
      @superclass_mismatch_change
    end

    def reversed
      superclass_mismatch_change
    end

    def mismatching_class
      superclass_mismatch_change.mismatching_class
    end

    def class_name
      superclass_mismatch_change.mismatching_class
    end

    def file_path
      superclass_mismatch_change.file_path
    end

    def old_superclass
      mismatching_class.superclass
    end

    def migration_string(identation = 0)
      " " * identation + [
        "# TypeError: superclass mismatch for #{class_name}",
        "# in #{file_path}",
        "#{class_name}.change_superclass_to #{old_superclass.name}"
      ].join("\n" + " " * identation)
    end

  end
end
