require "maglev_record/persistence"
require "maglev_record/enumerable"
require "rubygems"
require "active_support"
require "active_model"

module MaglevRecord
  module Base
    extend ActiveSupport::Concern
    extend ActiveModel::Naming

    @attributes = {}
    included do
      include ActiveModel
      include ActiveModel::AttributeMethods
      include ActiveModel::Conversion
      include ActiveModel::Dirty
      include ActiveModel::MassAssignmentSecurity
      include ActiveModel::Validations
      include MaglevRecord::Persistence
      include MaglevRecord::Enumerable

      Maglev::PERSISTENT_ROOT[self.name.to_sym] ||= Hash.new
      self.maglev_persistable
    end

    def save
      @previously_changed = changes
      @changed_attributes.clear
      Maglev::PERSISTENT_ROOT[self.class.name.to_sym][self.object_id] = self
    end

    def initialize(*args)
      if args.size == 1
        args[0].each do |k, v|
          self.send("#{k.to_s}=".to_sym, v)
        end
      end
    end

    private
    def attributes
      @attributes ||= {}
    end

    module ClassMethods
      def create(*args)
        x = self.new(*args)
        x
      end

      def clear
        Maglev::PERSISTENT_ROOT[self.name.to_sym].clear
      end

      def dirty_attr_accessor(*attr_names)
        attr_names.each do |attr_name|
          define_attribute_method(attr_name)

          generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{attr_name}=(new_value)
              #{attr_name}_will_change! unless new_value == attributes[:#{attr_name}]
              attributes[:#{attr_name}] = new_value
            end

            def #{attr_name}
              attributes[:#{attr_name}]
            end
          STR
        end
      end
    end

    def to_key
      key = self.__id__
      [key] if key
    end

  end
end
