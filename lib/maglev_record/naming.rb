module MaglevRecord
  class Name < String
    attr_reader :param_key, :singular

    def initialize(klass, namespace = nil, name = nil)
      name ||= klass.name

      raise ArgumentError, "Class name cannot be blank. You need to supply a name argument when anonymous class given" if name.blank?

      super(name)

      @unnamespaced = self.sub(/^#{namespace.name}::/, '') if namespace
      @klass        = klass
      @param_key    = klass.name.downcase
      @singular     = klass.name.downcase
    end

    def singular_route_key
      @singular
    end
  end

  module Naming
    # Returns an MaglevRecord::Name object for module. It can be
    # used to retrieve all kinds of naming-related information.
    def model_name
      @_model_name ||= begin
        namespace = self.parents.detect do |n|
          n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
        end
        MaglevRecord::Name.new(self, namespace)
      end
    end

    def self.singular_route_key(record_or_class)
      model_name_from_record_or_class(record_or_class).singular_route_key
    end


    private
      def self.model_name_from_record_or_class(record_or_class)
        (record_or_class.is_a?(Class) ? record_or_class : convert_to_model(record_or_class).class).model_name
      end

      def self.convert_to_model(object)
        object.respond_to?(:to_model) ? object.to_model : object
      end
  end

end
