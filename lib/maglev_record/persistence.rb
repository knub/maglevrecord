require "active_support"

module MaglevRecord
  module Persistence
    extend ActiveSupport::Concern

    def delete
      self.class.delete(self)
    end

    def save!(options = {})
      if options[:validate] == false or self.valid?
        @previously_changed = changes
        @changed_attributes.clear
        self.instance_variable_set(:@errors, nil)
        self.class.object_pool[self.object_id] = self
        @dirty = nil
        true
      else
        raise StandardError, "Model validation failed"
      end
    end

    def save(options = {})
      begin
        self.save!(options)
      rescue StandardError
        false
      end
    end

    def persisted?
      !new_record?
    end

    def new_record?
      !committed?
    end

    module ClassMethods
      def object_pool
        Maglev::PERSISTENT_ROOT[self.name.to_sym] ||= {}
      end

      def delete(*args)
        if block_given? and args.size == 0
          self.all.each do |m|
            self.object_pool.delete(m.object_id) if yield(m)
          end
        elsif !block_given? and args.size > 0
          args.each do |m|
            self.object_pool.delete(m.object_id)
          end
        else
          raise ArgumentError, "only block or arguments allowed"
        end
      end

      def clear
        self.object_pool.clear
      end
    end

  end
end

