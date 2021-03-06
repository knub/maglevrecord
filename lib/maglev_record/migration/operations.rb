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
        # TODO: test wether attribute is removed from attributes of class
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
        # TODO: test attribute names for string and for symbol
        each { |model|
          value = model.attributes.delete(name)
          yield value if block_given?
        }
        attributes.delete name.to_s if respond_to? :attributes
      end

      def migration_rename_to(new_name)
        old_name = name
        old_class = self
        nested_class = old_class.nesting_list[-2]
        Maglev.persistent do
          cls = nested_class.remove_const nesting_name_list[-1]
        end
        old_class.instance_eval "
          def name
            '#{(nesting_name_list[0...-1] + [new_name.to_s]).join('::')}'
          end
        "
        nested_class.const_set new_name, old_class
      end

      def migration_delete
        Maglev.persistent do
          nesting_list[-2].remove_const(nesting_name_list[-1])
        end
        delete_object_pool
      end

      def nesting_name_list
         self.name.split('::')
      end

      def nesting_list
        names = nesting_name_list
        list = [Object]
        names.each { |name|
          list << list[-1].const_get(name)
        }
        list
      end

      def remove_instance_method(name)
        begin
          remove_method name
        rescue NameError
        end
      end

      def remove_class_method(name)
        begin
          singleton_class.remove_method name
        rescue NameError
        end
      end

      def change_superclass_to(new_superclass)
        # remove the superclass to enable to change the superclass
        return unless new_superclass.is_able_to_become_superclass_of(self)
        _name = name
        Maglev.persistent do
          maglev_redefine {
            new_class = Object.module_eval "
              class #{_name} < #{new_superclass.name}
                self
              end"
            if respond_to? :object_pool_key
              # where should I put it else?
              raise "self should be object_pool_key" unless self == object_pool_key
              pool_pool = Maglev::PERSISTENT_ROOT[MaglevRecord::PERSISTENT_ROOT_KEY]
              unless pool_pool.nil?
                #TODO: test no instances while superclass change
                old_pool = pool_pool.delete(self) # TODO: test removed
                pool_pool[new_class] = old_pool unless old_pool.nil?
              end
            end
          }
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
      def remove_instance_method(name)
      end
      def remove_class_method(name)
      end
      def is_able_to_become_superclass_of(base_class)
        false
      end
      def change_superclass_to(new_superclass)
      end
    end
  end
end

Maglev.persistent do
  class Class
    def is_able_to_become_superclass_of(base_class)
      true
    end
  end
end
