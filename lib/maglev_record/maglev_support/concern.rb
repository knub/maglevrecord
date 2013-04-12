module MaglevSupport
  module Concern
    def included(base)
      self.included_modules.reverse.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
      (base.ancestors + [base]).each do |klass|
        # klass.included_modules.each do |mod|
        #   puts "Module: #{mod}"
        #   mod.maglev_persistable
        # end
        begin
          klass.maglev_persistable
        rescue Exception => e
          puts "====>Failed on #{klass}"
          raise e
        end

      end
      if base.is_a? Class #&& (self == MaglevRecord::RootedBase || self == MaglevRecord::Base)
        base.send :include, ActiveModel::Validations
        base.send :extend, Enumerable
      end
      Maglev.commit_transaction
    end
  end
end
