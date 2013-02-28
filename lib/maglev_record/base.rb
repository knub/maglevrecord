require "maglev_record/persistence"
require "maglev_record/read_write"
require "maglev_record/transaction_request_wrapper"
require "active_support"
require "active_model"

module MaglevRecord
  module Base

    @attributes = {}
    def self.included(base)

      # base.include ActiveModel
      # base.include ActiveModel::AttributeMethods
      # base.include ActiveModel::Conversion
      # base.include ActiveModel::MassAssignmentSecurity
      # base.include ActiveModel::Validations
      # base.include MaglevRecord::Persistence
      # base.include MaglevRecord::ReadWrite
      base.extend(ClassMethods)
      base.include ActiveModel::Validations
      base.include ActiveModel::MassAssignmentSecurity
      base.maglev_persistable
    end

    def initialize(*args)
      if args.size == 1
        args[0].each do |k, v|
          self.send("#{k.to_s}=".to_sym, v)
        end
      end
    end

    def attributes
      @attributes ||= {}
    end


    def to_key
      key = self.__id__
      [key] if key
    end

    module ClassMethods
      def create(*args)
        x = self.new(*args)
        x
      end
    end
  end
end
