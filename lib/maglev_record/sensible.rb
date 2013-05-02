module MaglevRecord
  module Sensible
    def sensibles
      self.class.sensibles
    end

    def clear_sensibles
      sensibles.each do |attribute|  
        send("#{attribute}=", nil)
      end
    end

    module ClassMethods
      def sensibles
        @maglev_sensible_attributes ||= Array.new
      end

      def mark_sensible(*attr_names)
        @maglev_sensible_attributes ||= Array.new unless attr_names.empty?
        attr_names.each do |attribute| 
          @maglev_sensible_attributes << attribute unless @maglev_sensible_attributes.include?(attribute)
        end
      end

    end

  end
end