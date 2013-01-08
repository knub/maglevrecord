require "maglev_record/persistence"

module Maglev
  module Base
    extend ActiveSupport::Concern

    included do
      include ActiveModel::MassAssignmentSecurity
      include ActiveModel::Validations
      include ActiveModel::AttributeMethods
      include ::MaglevRecord::Persistence

      Maglev::PERSISTENT_ROOT[self] ||= Hash.new
    end

    module InstanceMethods
      def a
        puts "a"
      end

# Test Memento
# d = Book.dummy
# d.memento
# d.title = "XXX"
# d.reset
      def memento
        return if !@memento.nil?
        m = Memento.new
        @attributes.each do |k,v|
          if v.class.included_modules.include? Maglev::Base
            m.backup[k] = v
          else
            m.backup[k] = if v == nil then nil else v.clone end
          end
        end
        @memento = m
        m
      end

      def force_memento
        @memento = nil
        memento
      end

      def reset
        return if @memento.nil?

        @memento.backup.each do |k, v|
          @attributes[k] = v
          if v.class.included_modules.include? Maglev::Base
            v.reset
          end
        end
        @memento = nil
        self
      end


      def validate
        puts "Validating"
        @memento = nil
        true
      end
    end

    module ClassMethods
      def find(id)
        Maglev::PERSISTENT_ROOT[self][id]
      end

      def all
        Maglev::PERSISTENT_ROOT[self].values
      end

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
      memento
      @attributes[attr_name]
    end

    def write_attribute(attr_name, value)
      memento
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