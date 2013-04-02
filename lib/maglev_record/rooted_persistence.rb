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

      def new(*args)
        instance = super(*args)
        self.object_pool[instance.id] = instance
        instance
      end

      def clear
        self.object_pool.clear
      end

      def create(*args)
        instance = new(*args)
        MaglevRecord.save
        instance
      end
    end
  end
end