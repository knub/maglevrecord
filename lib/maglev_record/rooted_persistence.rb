require "maglev_record/enumerable"
require "maglev_record/persistence"

module MaglevRecord
  module RootedPersistence
    include MaglevRecord::Enumerable
    include MaglevRecord::Persistence
    
    def self.included(base)
      base.extend(ClassMethods)
      self.included_modules.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
    end

    def delete
      self.class.object_pool.delete(self.id)
    end

    def id
      object_id
    end

    module MaglevPersistence
      def object_pool_key
        self
      end

      def object_pool
        Maglev::PERSISTENT_ROOT[MaglevRecord::PERSISTENT_ROOT_KEY] ||= {}
        Maglev::PERSISTENT_ROOT[MaglevRecord::PERSISTENT_ROOT_KEY][object_pool_key] ||= {}
      end

      def save(obj)
        self.object_pool[obj.id] = obj
      end
    end
        
    module ClassMethods
      include MaglevRecord::RootedPersistence::MaglevPersistence

      def clear
        self.object_pool.each { |k, v|
          v.delete
        }
      end

      # is defiened in Enumerable
      # def size
      #   self.object_pool.size
      # end

      def new(*args)
        instance = super(*args)
        self.object_pool[instance.id] = instance
        instance
      end
    end

  end
end
