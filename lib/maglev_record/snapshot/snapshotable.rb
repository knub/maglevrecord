require "maglev_record/maglev_support/concern"

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
        # In nested transaction this error occurs:
        # Error 2101, objId i52279553 does not exist, during transaction boundary
        fp = file_paths
        without_methods do
          fp.each{ |file_path|
            Kernel.load file_path if File.file? file_path
          }
          return !file_paths.empty?
        end
      end

      def without_methods
        return unless block_given?
        memento = reset
        begin
          yield
        ensure
          memento.call
        end
      end

      #
      # resets the class to no methods, no attributes 
      # returns a memento proc that can be called to restore the old state
      #
      def reset
        _instance_methods = instance_methods(false).map { |m|
          meth = instance_method m
          remove_method m
          meth
        }
        _class_methods = methods(false).map { |m|
          meth = method m
          singleton_class.remove_method m
          meth
        }
        return Proc.new{
          puts "restoring #{_instance_methods} #{_class_methods}"
          instance_methods(false).each { |m| remove_method m }
          methods(false).each{ |m| singleton_class.remove_method m }
          _instance_methods.each{|m|
            define_method m.name, m
          }
          _class_methods.each{|m|
            singleton_class.define_method m.name, m
          }
        }
      end
    end
  end
end
