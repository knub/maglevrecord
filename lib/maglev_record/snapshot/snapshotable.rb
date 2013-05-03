Maglev.persistent do
  class ::Class
    def exist!
      @exists = true
    end

    def start_existence_test!
      @exists = false
    end

    def exists?
      return true if @exists
      false
    end
  end
end

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

    module ClassMethods

      def self.extended(base)
        base.exist! if base.respond_to? :exist!
      end

      def file_paths
        (self.instance_methods(false).map { |m|
          self.instance_method(m).source_location.first
        } + self.methods(false).map { |m|
          self.method(m).source_location.first
        }).uniq
      end

      def has_definitions?
        # TODO: maybe in a nested transaction?
        start_existence_test!
        file_paths.each{ |file_path|
          Kernel.load file_path if File.file? file_path
          return true if exists?
        }
        exists?
      end
    end
  end
end
