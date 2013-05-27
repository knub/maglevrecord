module MaglevSupport
  module Concern
    def included(base)
      self.included_modules.reverse.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
      self.reinclude_store.each do |mod|
        base.__save_for_reinclude(mod)
      end unless self.reinclude_store.nil?
      if base.is_a? Class
        base.send :redo_extend, Enumerable
        base.send :redo_extend, MaglevSupport.constantize("ActiveModel::Naming")
      end
      #Maglev.commit_transaction
    end
  end
end
