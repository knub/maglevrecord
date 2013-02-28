require "active_support"

module MaglevRecord
  module Enumerable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      include ::Enumerable

      def each
        self.object_pool.each_value do |el|
          yield(el)
        end
      end

      def size
        self.object_pool.size
      end
      
      alias_method :length, :size

      def find_by_objectid(id)
        self.object_pool[id]
      end

      def all
        self.object_pool.values
      end
    end
  end

end

