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
          without_methods do
            fp.each{ |file_path|
              Kernel.load file_path if File.file? file_path
            }
            return !file_paths.empty?
          end
        ensure
          Maglev.abort_transaction
        end
      end

      def without_methods
        return unless block_given?
        instance_methods = instance_methods(false).map { |m|
          meth = instance_method m
          remove_method m
          meth
        }
        class_methods = methods(false).map { |m|
          meth = method m
          singleton_class.remove_method m
          meth
        }
        begin
          yield
        ensure
          instance_methods(false).each { |m| remove_method m }
          methods(false).each{ |m| singleton_class.remove_method m }
          instance_methods.each{|m|
            define_method m.name, m
          }
          class_methods.each{|m|
            singleton_class.define_method m.name, m
          }
        end
      end
    end
  end
end
