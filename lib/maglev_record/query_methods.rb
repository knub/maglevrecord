require "active_support"

module MaglevRecord
  module QueryMethods
    extend ActiveSupport::Concern

    module InstanceMethods

    end
attr_writer :attr_names
    module ClassMethods
      def find(id)
        Maglev::PERSISTENT_ROOT[self][id]
      end

      def all
        Maglev::PERSISTENT_ROOT[self].values
      end
    end

  end

end

