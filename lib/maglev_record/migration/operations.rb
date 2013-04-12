
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
      def migration_rename_to(new_name)
        old_name = name
        old_class = self
        Maglev.persistent do
          cls = Object.remove_const old_name
        end
        old_class.instance_eval "
          def name
            '#{new_name.to_s}'
          end
        "
        Object.const_set new_name, old_class
      end
      def migration_delete
        cls = self
        Maglev.persistent do
          Object.remove_const(cls.name.to_sym)
        end
      end
    end
    class NullClass
      include ClassMethods
      def initialize(name)
        @name = name
      end
      def new(*args)
        # TODO: test
        raise "This class #{@name} has not been created"
      end
      def each
      end
      def migration_rename_to(new_name)
      end
      def migration_delete
      end
    end
  end
end

