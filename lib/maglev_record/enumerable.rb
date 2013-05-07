module MaglevRecord
  module Enumerable
    module ClassMethods
      def all
        raise "method not available for MaglevRecord::Base"
      end
      def each
        raise "method not available for MaglevRecord::Base"
      end
      def size
        raise "method not available for MaglevRecord::Base"
      end
      def find_by_objectid(id)
        raise "method not available for MaglevRecord::Base"
        # if id.respond_to? :to_i
        #   id = id.to_i 
        # else
        #   raise "#{id} do not respond to :to_i!"
        # end
        # ObjectSpace._id2ref(id)
      end
    end
  end
end