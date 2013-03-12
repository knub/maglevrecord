
module MaglevRecord
  module Enumerable

    def self.included(base)
      base.extend(ClassMethods)
      self.included_modules.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
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
        raise "cannot convert #{id} to fixnum!" unless id.respond_to? :to_i
        self.object_pool[id.to_i]
      end

      def all
        self.object_pool.values
      end
    end
  end

end

