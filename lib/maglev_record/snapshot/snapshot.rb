require "maglev_record/snapshot/snapshotable"
require "maglev_record/snapshot/class_snapshot"
require "maglev_record/snapshot/change"

module MaglevRecord

  class Snapshot

    def for_class(cls)
      ClassSnapshot.new(cls)
    end

    def initialize(classes = Snapshotable.snapshotable_classes)
      @class_snapshots = classes.map{ |cls|
        for_class cls
      }
    end

    def changes_since(older)
      Change.new(older, self)
    end

    def class_snapshots
      Array.new(@class_snapshots)
    end

    def snapshot_classes
      class_snapshots.map(&:snapshot_class)
    end

    def class_names
      class_snapshots.map(&:class_name).sort
    end

    def [](cls)
      class_snapshots.each{ |snap|
        return snap if snap.snapshot_class == cls
      }
    end

    def self.with_files(file_paths = [], classes = Snapshotable.snapshotable_classes)
      class_files = classes.map(&:file_paths).flatten.uniq
      restore_state = classes.map(&:reset)
      begin
      (file_paths + class_files).uniq.each{ |file_path|
        begin
          Kernel.load file_path if File.exist? file_path
        rescue TypeError => e
          class_name = e.message[/superclass mismatch for( class)? (\S*)$/, 2]
          raise e if class_name.nil? # TODO: test
          raise e unless Object.const_defined? class_name # TODO: test
          cls = Object.const_get class_name # TODO: rescue exceptions
          return SuperclassMismatchChange.new(cls, file_path)
        end
      }
      else
        return new
      ensure
        restore_state.map(&:call)
      end
    end

    def new_with_files(file_paths = [])
      self.class.with_files(file_paths)
    end

    def changes_in_files(file_paths = [])
      return new_with_files(file_paths).changes_since(self)
    end
  end
end

