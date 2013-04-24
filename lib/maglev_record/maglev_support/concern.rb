module MaglevSupport
  module Concern
    def included(base)
      self.included_modules.reverse.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
      (base.ancestors + [base]).each do |klass|
        begin
          # klass.maglev_persistable
        rescue Exception => e
          puts "====>Failed on #{klass}"
          raise e
        end
      end
      if base.is_a? Class #&& (self == MaglevRecord::RootedBase || self == MaglevRecord::Base)
        # base.send :include, ActiveModel::Validations
        base.send :extend, Enumerable
        base.send :extend, MaglevSupport.constantize("ActiveModel::Naming")
      end
      Maglev.commit_transaction
    end
  end
end
