
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
      def delete_instance_variable(name)
        each { |model|
          value = model.instance_variable_get(name)
          yield value if block_given?
          model.remove_instance_variable name.to_s
        }
      end
      def delete_attribute(name)
        each { |model|
          value = model.attributes.delete(name)
          yield value if block_given?
        }
      end
    end
    class NullClass
      include ClassMethods
      def initialize(name)
        @name = name
      end
      def new
        # TODO: test
        raise "This class #{@name} has not been created"
      end
      def each
      end
    end
  end
end

