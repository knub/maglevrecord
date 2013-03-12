
module MaglevRecord
  module ReadWrite

    def self.included(base)
      base.extend(ClassMethods)
      self.included_modules.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
    end

    # def update_attributes(hash)
    #   for att, value in hash
    #     self.send(att+"=", value)
    #   end
    # end

    module ClassMethods
      def attr_reader(*attr_names)
        attr_names.each do |attr_name|
          define_attribute_method(attr_name)

          generated_attribute_methods.module_eval <<-ATTRREADER, __FILE__, __LINE__ + 1
            def #{attr_name}
              attributes[:#{attr_name}]
            end
          ATTRREADER
        end
      end

      def attr_writer(*attr_names)
        attr_names.each do |attr_name|
          define_attribute_method(attr_name)

          generated_attribute_methods.module_eval <<-ATTRWRITER, __FILE__, __LINE__ + 1
            def #{attr_name}=(new_value)
              attributes[:#{attr_name}] = new_value
            end
          ATTRWRITER
        end
      end

      def attr_accessor(*attr_names)
        attr_reader *attr_names
        attr_writer *attr_names
      end
    end
  end
end

