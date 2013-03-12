
module MaglevSupport
  module Concern
    def included(base)
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
      self.included_modules.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
    end
  end
end