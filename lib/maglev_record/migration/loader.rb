require "maglev_record/migration"

##
# Offers methods for reading migrations from strings, files and directories.
# Migrations are sorted and dou
# All read in migrations can be accessed after the reading.
module MaglevRecord
  class MigrationLoader

    def initialize
      @migration_list = []
    end

    def migration_list
      # TODO
      # Print a warning, if there are two or more migrations which are equal.
      @migration_list.sort.uniq
    end

    def load_string(source, file = __FILE__)
      migration = instance_eval source, file
      # TODO: Check class of migration is really migration!
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
