module MaglevRecord
  module Enumerable

    module ClassMethods
      def size
        object_pool.size
      end
    end
  end
end