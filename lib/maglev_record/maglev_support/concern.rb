
class Module
  def include_with_block(a_module)
    value = include_without_block(a_module)
    yield(self) if block_given?
    value
  end
  alias :include_without_block :include
  alias :include :include_with_block
end

module MaglevSupport
  module Concern
    def included(base)
      self.included_modules.reverse.each do |mod|
        base.extend(mod::ClassMethods) if mod.constants.include? 'ClassMethods'
      end
      base.extend(self::ClassMethods) if self.constants.include? 'ClassMethods'
      ([base] + base.ancestors).each do |klass|
        klass.maglev_persistable
      end
      Maglev.commit_transaction
    end
  end
end