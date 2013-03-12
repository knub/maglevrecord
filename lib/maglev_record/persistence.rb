module MaglevRecord
  module Persistence
    extend MaglevSupport::Concern

    def initialize(*args)
      if args.size == 1
        args[0].each do |k, v|
          self.send("#{k.to_s}=".to_sym, v)
        end
      end
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