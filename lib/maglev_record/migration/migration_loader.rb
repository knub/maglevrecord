require "maglev_record/migration"

module MaglevRecord
  class MigrationLoader

    def initialize
      @migration_list = []
    end

    def migration_list
      @migration_list.sort
    end

    def load_string(source, file = __FILE__)
      migration = instance_eval source, file
      migration.source = source
      @migration_list << migration
    end

    def load_file(file_path)
      raise ArgumentError, "file #{file_path.inspect} not found" unless File.file?(file_path)
      load_string(File.open(file_path).read, file_path)
    end

    def load_directory(directory_path)
      Dir.foreach(directory_path) { |file_name|
        load_file(directory_path + '/' + file_name) if file_name.end_with? '.rb'
      }
    end
  end
end
