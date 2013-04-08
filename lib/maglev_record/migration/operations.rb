
module MaglevRecord
  module MigrationOperations
    module ClassMethods
      def rename_instance_variable(old_name, new_name)
        each { |model|
          value = model.instance_variable_get(old_name)
          value = yield value if block_given?
          model.remove_instance_variable old_name.to_s
          model.instance_variable_set(new_name, value)
        }
      end
      def rename_attribute(old_name, new_name)
        attr_accessor new_name
        each { |model|
          value = model.attributes[old_name]
          value = yield value if block_given?
          model.attributes.delete old_name
          model.attributes[new_name] = value
        }
      end
    end
  end
end

