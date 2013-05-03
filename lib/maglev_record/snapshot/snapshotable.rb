module MaglevRecord
  module Snapshotable
    def self.snapshotable_classes
      classes = []
      Object.constants.each { |constant| 
        begin
          cls = Object.const_get constant
        rescue Exception
        else
          classes << cls if cls.is_a? Class and cls.ancestors.include? self
        end
      }
      classes
    end
  end
end
