require "active_support"

module MaglevRecord
  module QueryMethods
    extend ActiveSupport::Concern

    module InstanceMethods

    end

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

