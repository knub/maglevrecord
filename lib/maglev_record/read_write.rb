require "active_support"

module MaglevRecord
  module ReadWrite
    extend ActiveSupport::Concern

    included do
      # puts self
      # puts self.class
      # self.class.define_method(:attr_accessor_with_maglev_persistence) do |*args|
      #   puts "in attr_reader"
      #   puts args
      #   self.class.attr_reader_without_maglev_persistence
      # end
    end

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
              #{attr_name}_will_change! unless new_value == attributes[:#{attr_name}]
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

