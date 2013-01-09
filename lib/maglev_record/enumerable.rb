require "active_support"

module MaglevRecord
  module Enumerable
    extend ActiveSupport::Concern
        
    module InstanceMethods

    end
    
    module ClassMethods
      include ::Enumerable

      def each
        self.all.each do |el|
          yield(el)
        end
      end

      def size
        Maglev::PERSISTENT_ROOT[self.name.to_sym].size
      end

      alias_method :length, :size

      def find_by_objectid(id)
        Maglev::PERSISTENT_ROOT[self.name.to_sym][id]
      end

      def all
        Maglev::PERSISTENT_ROOT[self.name.to_sym].values
      end

    end

  end

end

