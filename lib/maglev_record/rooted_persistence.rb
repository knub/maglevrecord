module MaglevRecord
  module RootedPersistence
    extend MaglevSupport::Concern


    module ClassMethods
      def object_pool_key
        self
      end

      def object_pool
        Maglev::PERSISTENT_ROOT[MaglevRecord::PERSISTENT_ROOT_KEY] ||= {}
        Maglev::PERSISTENT_ROOT[MaglevRecord::PERSISTENT_ROOT_KEY][object_pool_key] ||= {}
      end

      def clear
      end

      def create
      end
    end
  end
end