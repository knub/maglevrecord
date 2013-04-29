module MaglevRecord
  module Snapshotable
    def self.snapshotable_classes
      classes = []
      ObjectSpace.each_object(Class) { |scls|
        # scls is the <Class:Object> -> get Object
        ObjectSpace.each_object(scls) { |cls|
          classes << cls if cls.ancestors.include? self
        }
      }
      classes
    end
  end
  Snapshotable.maglev_persistable(true)
end
