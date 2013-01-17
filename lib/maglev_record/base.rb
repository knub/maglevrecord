require "maglev_record/persistence"
require "maglev_record/read_write"
require "maglev_record/transaction_request_wrapper"
require "rubygems"
require "active_support"
require "active_model"

module MaglevRecord
  module Base
    extend ActiveSupport::Concern
    extend ActiveModel::Naming

    @attributes = {}
    included do
      include ActiveModel
      include ActiveModel::AttributeMethods
      include ActiveModel::Conversion
      include ActiveModel::MassAssignmentSecurity
      include ActiveModel::Validations
      include MaglevRecord::Persistence
      include MaglevRecord::ReadWrite

      self.maglev_persistable
      ActiveSupport.maglev_persistable
      #ActiveSupport::HashWithIndifferentAccess.maglev_persistable
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

    module ClassMethods
      def create(*args)
        x = self.new(*args)
        x
      end
    end

    def to_key
      key = self.__id__
      [key] if key
    end

  end
end
