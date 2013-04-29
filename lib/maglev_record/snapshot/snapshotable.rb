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
      ## this is a very generic version that is very slow
      #ObjectSpace.each_object(Class) { |scls|
      #  # scls is the <Class:Object> -> get Object
      #  ObjectSpace.each_object(scls) { |cls|
      #    classes << cls if cls.ancestors.include? self
      #  }
      #}
      classes
    end
  end
  #Snapshotable.maglev_persistable(true)
end
