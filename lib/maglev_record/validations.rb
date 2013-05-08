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
      def validates(*attributes)
        @validates_options ||= []
        @validates_options << attributes
      end

      def create_validations
        @validates_options.each do |opts|
          self.validates *opts
        end
      end
    end
  end
end