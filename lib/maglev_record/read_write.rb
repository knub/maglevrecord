
module MaglevRecord
  module ReadWrite
    extend MaglevSupport::Concern

    def attributes
      @maglev_attributes ||= Hash.new 
    end

    def update_attributes(attribute_hash)
      attribute_hash.each_pair do |k,v|
        attributes[k.to_sym] = v
      end
      self
    end

    module ClassMethods
      def attr_reader(*attr_names)
        attr_names.each do |attr_name|
          attributes << attr_name.to_s
          self.module_eval <<-ATTRREADER, __FILE__, __LINE__ + 1
            def #{attr_name}
              attributes[:#{attr_name}]
            end
          ATTRREADER
        end
      end

      def attr_writer(*attr_names)
        attr_names.each do |attr_name|
          attributes << attr_name.to_s
          self.module_eval <<-ATTRWRITER, __FILE__, __LINE__ + 1
            def #{attr_name}=(new_value)
              updated
              attributes[:#{attr_name}] = new_value
            end
          ATTRWRITER
        end
      end


      def attr_accessor(*attr_names)
        attr_reader *attr_names
        attr_writer *attr_names
      end

      def attributes
        @attributes ||= []
        @attributes.sort!
        @attributes.uniq!
        @attributes
      end
    end
  end
end

