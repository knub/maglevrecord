module MaglevRecord
  module Persistence
    extend MaglevSupport::Concern

    def initialize(*args)
      if args.size == 1
        args[0].each do |k, v|
          meth_name = "#{k.to_s}=".to_sym
          self.send(meth_name, v) if self.respond_to? meth_name
        end
      end
      created
    end

    def created_at
      @created_at_timestamp
    end
    def created
      @created_at_timestamp = Time.now
    end

    def updated_at
      @updated_at_timestamp
    end
    def updated
      @updated_at_timestamp = Time.now
    end

    alias :persisted? :committed?
    def new_record?
      !persisted?
    end

    def id
      object_id
    end

    module ClassMethods
      def clear
        raise MaglevRecord::InvalidOperationError, "Do not use clear without including MaglevRecord::RootedBase."
      end

      def create
        raise MaglevRecord::InvalidOperationError, "Do not use create without including MaglevRecord::RootedBase."
      end
    end
  end
end
