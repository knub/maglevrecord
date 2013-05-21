require "maglev_record/maglev_support/concern"


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
    extend MaglevSupport::Concern

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
        Maglev.begin_nested_transaction
        begin
          fp = file_paths
          remove_all_methods
          fp.each{ |file_path|
            Kernel.load file_path if File.file? file_path
          }
          return !file_paths.empty?
        ensure
          Maglev.abort_transaction
        end
      end

      def remove_all_methods
        self.instance_methods(false).map { |m|
          remove_method m
        }
        self.methods(false).map { |m|
          singleton_class.remove_method m
        }
      end
    end
  end
end
