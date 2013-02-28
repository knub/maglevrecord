require "active_support"
require "maglev_record/enumerable"

module MaglevRecord
  module RootedPersistence
    include MaglevRecord::Enumerable

    def self.included(base)
      base.extend(ClassMethods)
    end

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

      def object_pool_key
        self.name.to_sym
      end

      def object_pool
        Maglev::PERSISTENT_ROOT[object_pool_key] ||= {}
      end
    end

  end
end
