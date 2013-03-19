module MaglevRecord
  module Enumerable
    module ClassMethods
      def all
        object_pool.values
      end
      def each
        object_pool.each_value do |model|
          yield model
        end
      end
      def size
        object_pool.size
      end
      def find_by_objectid(id)
        object_pool[id]
      end
    end
  end
end