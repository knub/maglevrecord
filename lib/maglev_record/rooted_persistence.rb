require "active_support"

module MaglevRecord
  module RootedPersistence
    extend ActiveSupport::Concern
    include MaglevRecord::Enumerable

    def delete
      self.class.object_pool.delete(self.id)
    end

    def id
      object_id
    end

    module ClassMethods
      def clear
        self.object_pool.each { |k, v|
          v.delete
        }
      end

      def size
        self.object_pool.size
      end

      def new(*args)
        instance = super(*args)
        self.object_pool[instance.id] = instance
        instance
      end

      def object_pool
        Maglev::PERSISTENT_ROOT[self.name.to_sym] ||= {}
      end
    end
  end

end

