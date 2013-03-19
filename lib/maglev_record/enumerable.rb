module MaglevRecord
  module Enumerable

    def each
      object_pool.each_value do |model|
        yield model
      end
    end

    module ClassMethods
      def size
        object_pool.size
      end
    end
  end
end