module MaglevRecord
  module Validations
    def self.included(base)
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
    end

    def method_missing(symbol, *args)
      self.class.create_validations
      if self.respond_to?(symbol)
        send(symbol, *args)
      else
        super
      end
    end

    module ClassMethods

      def method_missing(symbol, *args)
        super unless symbol.to_s.include? "valid"

        @validates_options ||= Hash.new
        @validates_options[symbol] ||= []
        @validates_options[symbol] << args
      end

      def create_validations
        return if not self.maglev_persistable? or @validates_options.nil?

        self.include MaglevSupport.constantize("ActiveModel::Validations")
        @validates_options.each do |symbol, args_list|
          args_list.each do |args|
            self.send(symbol, *args)
          end
        end
        @validates_options = nil
      end

      def reset
        _validates_options = @validates_options
        @validates_options = nil
        reset_proc = super
        return Proc.new {
          reset_proc.call
          @validates_options = _validates_options
        }
      end
    end
  end
end
