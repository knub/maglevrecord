require "maglev_record/persistence"
require "maglev_record/query_methods"
require "rubygems"
require "active_support"
require "active_model"

module Maglev
  module Base
    extend ActiveSupport::Concern
    extend ActiveModel::Naming

    included do
      include ActiveModel::AttributeMethods
      include ActiveModel::Conversion
      include ActiveModel::Dirty
      include ActiveModel::MassAssignmentSecurity
      include ActiveModel::Validations
      include MaglevRecord::Persistence
      include MaglevRecord::QueryMethods

      Maglev::PERSISTENT_ROOT[self] ||= Hash.new
    end

    module InstanceMethods
      def save
        changed_attributes.each do |k, v|
          @attributes[k] = v
        end
        changed_attributes.clear
        @dirty = nil
        Maglev::PERSISTENT_ROOT[self.class.to_s.to_sym][self.object_id] = self
      end
    end

    module ClassMethods
      def create(*args)
        x = self.new(*args)
        x
      end

      def initialize_attributes(attributes)
        #super
        ## ...

        attributes
      end

      def default_attributes
        Hash.new
      end

      ## Copied from .rbenv/verions/maglev/lib/maglev/gems/1.8/gems/activerecord-3.2.3/lib/active_record/attribute_methods/read.rb
      def define_method_attribute(attr_name)
        generated_attribute_methods.module_eval(
          "def #{attr_name}; read_attribute('#{attr_name}'); end",
           __FILE__, __LINE__)

      end

      ## Copied from .rbenv/verions/maglev/lib/maglev/gems/1.8/gems/activerecord-3.2.3/lib/active_record/attribute_methods/write.rb
      def define_method_attribute=(attr_name)
        if attr_name =~ ActiveModel::AttributeMethods::NAME_COMPILABLE_REGEXP
          generated_attribute_methods.module_eval("def #{attr_name}=(new_value); write_attribute('#{attr_name}', new_value); end", __FILE__, __LINE__)
        else
          generated_attribute_methods.send(:define_method, "#{attr_name}=") do |new_value|
            write_attribute(attr_name, new_value)
          end
        end
      end

    end

    def to_key
      key = self.__id__
      [key] if key
    end

    def initialize(attributes = nil, options = {})
      @attributes = self.class.initialize_attributes(self.class.default_attributes.dup)
      @attributes_cache = {}

      self._accessible_attributes[:default].each do |attr_name|
        self.class.define_method_attribute(attr_name)
        self.class.define_method_attribute=(attr_name)
        @attributes[attr_name] = nil
      end

    end


    ## Copied from .rbenv/verions/maglev/lib/maglev/gems/1.8/gems/activerecord-3.2.3/lib/active_record/attribute_methods/{write.rb, read.rb}
    def read_attribute(attr_name)
      @attributes[attr_name]
    end

    def write_attribute(attr_name, value)
      @attributes[attr_name] = value
    end

    private
      def attribute(attribute_name)
        read_attribute(attribute_name)
      end

      def attribute=(attribute_name, value)
        write_attribute(attribute_name, value)
      end
  end
end