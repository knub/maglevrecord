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

      def class_methods_not_to_snapshot
        @class_methods_not_to_reset ||= []
        # hackady hack!
        # welcome to the big ball of mud and the 
        # "I do not know what goes on after hours trying"-architecture
        @class_methods_not_to_reset << "_validators"
        @class_methods_not_to_reset << "name"
        @class_methods_not_to_reset << "_validators="
        @class_methods_not_to_reset << "_validators?"
        #@class_methods_not_to_reset << "method_missing"
        @class_methods_not_to_reset << methods(false).select{|m| m.include? "callback" }
        @class_methods_not_to_reset.flatten!
        @class_methods_not_to_reset.map!(&:to_s)
        @class_methods_not_to_reset.uniq!
        @class_methods_not_to_reset
      end

      def snapshot_class_methods
        methods(false) - class_methods_not_to_snapshot
      end

      def snapshot_instance_methods
        instance_methods(false).reject{|m| m.include? 'callback' or m.include? 'valid'}
      end

      def class_methods_to_reset
        snapshot_class_methods
      end

      def instance_methods_to_reset
        snapshot_instance_methods
      end

      #
      # resets the class to no methods
      # returns a memento proc that can be called to restore the old state
      #
      def reset
        _instance_methods = instance_methods_to_reset.map { |m|
          meth = instance_method m
          remove_method m
          meth
        }
        _class_methods = class_methods_to_reset.map { |m|
          meth = method m
          singleton_class.remove_method m
          meth
        }
        return Proc.new {
          instance_methods_to_reset.each { |m| remove_method m }
          class_methods_to_reset.each{ |m| singleton_class.remove_method m }
          _instance_methods.each{|m|
            define_method m.name, m
          }
          _class_methods.each{|m|
            singleton_class.define_method m.name, m
          }
          self
        }
      end
    end
  end
end
