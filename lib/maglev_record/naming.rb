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
      @singular    = klass.name.downcase
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
  end

end
