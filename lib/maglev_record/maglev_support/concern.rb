module MaglevSupport
  module Concern
    def included(base)
      self.included_modules.reverse.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
      self.reinclude_store.each do |mod|
        base.__save_for_reinclude(mod)
      end unless self.reinclude_store.nil?
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
      if base.is_a? Class
        base.send :redo_include, ActiveModel::Validations
        base.send :extend, Enumerable
        base.send :extend, MaglevSupport.constantize("ActiveModel::Naming")
      end
      Maglev.commit_transaction
    end
  end
end
