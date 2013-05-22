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
      (file_paths + class_files).uniq.each{ |file_path|
        begin
          Kernel.load file_path if File.exist? file_path
        rescue Exception => e
          restore_state.map(&:call)
          return yield e, file_path if block_given?
          raise e
        end
      }
      new
    end

    def new_with_files(file_paths = [], &block)
      self.class.with_files(file_paths, &block)
    end

    def changes_in_files(file_paths = [])
      return new_with_files(file_paths){ |error, path|
        SuperclassMismatchChange.new(error, path)
      }.changes_since(self)
    end
  end
end

