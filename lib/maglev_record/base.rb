require "maglev_record/enumerable"
require "maglev_record/persistence"
require "maglev_record/read_write"
require "maglev_record/naming"
require "maglev_record/integration"
require "maglev_record/transaction_request_wrapper"
require "active_support/dependencies"
require "active_model/naming"


module MaglevRecord
  module Base
    extend MaglevRecord::RootedPersistence::MaglevPersistence
    extend MaglevRecord::Enumerable::ClassMethods

    include MaglevRecord::Integration


    def self.object_pool_key
      :base
    end

    @attributes = {}

    def self.included(base)
      base.extend(ClassMethods)
      ##base.extend(ActiveModel::Naming)

      self.included_modules.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? "ClassMethods"
      end

      base.maglev_persistable
      self.save(base)
      Maglev.commit_transaction
    end

    # Initialize existing (persisted) model classes
    def self.load_model_files
      self.all.each do |model|
        name = ActiveSupport::Dependencies.qualified_name_for(Object, model).underscore
        file = ActiveSupport::Dependencies.search_for_file(name)

        if (file)
          ActiveSupport::Dependencies.require_or_load(file)
        else
          warn "Cannot find model file for #{name}"
        end
      end
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

      def id
        object_id
      end
    end
  end
end

