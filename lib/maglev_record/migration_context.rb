require "maglev_record/migration_context_timestamp"

module MaglevRecord

  #
  # Migrations are loaded in MigrationContexts
  # The migration context defines methods that can be used to migrate
  #
  class MigrationContext

    def initialize(migration_factory)
      @migration_factory = migration_factory
    end

    def load_string(source, file = __FILE__)
      @source = source
      value = instance_eval source, file
      @source = nil
      value
    end

    attr_reader :source

    def load_file(file_path)
      raise ArgumentError, "file #{file_path.inspect} not found" unless File.file?(file_path)
      load_string(File.open(file_path).read)
    end

    def load_directory(directory_path)
      Dir.foreach(directory_path){ |file_name|
        load_file(directory_path + '/' + file_name) if file_name.end_with? '.rb'
      }
    end

    def migration(timestamp_string)
      _timestamp = timestamp(timestamp_string)
      migration = @migration_factory.migration(_timestamp)
      migration.source = source
      migration
    end

    def first_migration
      @migration_factory.first_migration
    end

    def timestamp(string)
      Timestamp.parse(string)
    end
  end
end
