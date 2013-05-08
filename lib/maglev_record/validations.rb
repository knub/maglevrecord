module MaglevRecord
  module Validations
    def self.included(base)
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
    end

    def method_missing(symbol, *args)
      if self.class.maglev_persistable?
        self.class.include MaglevSupport.constantize("ActiveModel::Validations")
        self.class.create_validations
        if self.respond_to?(symbol)
          send(symbol, *args)
        else
          super
        end
      else
        super
      end
    end

    module ClassMethods
      def method_missing(symbol, *args)
        if symbol.to_s.include? "valid"
          @validates_options ||= Hash.new
          @validates_options[symbol] ||= []
          @validates_options[symbol] << args
        else
          super
        end
      end

      def create_validations
        @validates_options.each do |symbol, args_list|
          args_list.each do |args|
            self.send(symbol, *args)
          end
        end
      end
    end
  end
end