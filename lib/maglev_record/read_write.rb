
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

      #
      # resets the class to no methods
      # returns a memento proc that can be called to restore the old state
      #
      def attributes
        @attributes ||= []
        raise TypeError, "attributes contain bad elements #{@attributes}" unless @attributes.all?{ |attribute| attribute.is_a? String }
        @attributes.sort!
        @attributes.uniq!
        @attributes
      end

      def reset
        _attributes = attributes_to_reset.map{ |attribute|
          attributes.delete attribute
        }
        reset_proc = super if defined?(super)
        return Proc.new {
          reset_proc.call unless reset_proc.nil?
          _attributes.each{ |attribute| attributes << attribute}
          attributes
          self
        }
      end

      def snapshot_attributes
        attributes.reject{|attribute| attribute.include? 'valid' }
      end

      def attributes_to_reset
        snapshot_attributes
      end
    end
  end
end

