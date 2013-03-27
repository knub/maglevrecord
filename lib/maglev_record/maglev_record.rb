module MaglevRecord
  PERSISTENT_ROOT_KEY = :MaglevRecord

  def self.save
    Maglev.commit_transaction
  end

  def self.reset
    Maglev.abort_transaction
  end
end

MaglevRecord.maglev_persistable

ActiveModel.maglev_persistable(true)
ActiveSupport.maglev_persistable(true)

ActiveModel::Validations.maglev_persistable(true)
ActiveModel::Errors.maglev_persistable(true)
ActiveModel::Conversion.maglev_persistable(true)

ActiveSupport::OrderedHash.maglev_persistable(true)
ActiveSupport::Autoload.maglev_persistable(true)
ActiveSupport::Inflector.maglev_persistable(true)
ActiveSupport::Inflector::Inflections.maglev_persistable(true)


module ActiveSupport
  class << Deprecation
    # Declare that a method has been deprecated.
    def deprecate_methods(target_module, *method_names)
      options = method_names.extract_options!
      method_names += options.keys
      method_names.each do |method_name|
        next unless method_name.respond_to?(:to_sym)  # next if Fixnum
        next if method_name == :none                  # check from rubygems/deprecate.rb
        next if method_name.to_s.include?(".")             # . in method names is not allowed
        # workaround for :==
        if method_name.to_sym == :==
          method_name = "equal?"
        end
        target_module.alias_method_chain(method_name, :deprecation) do |target, punctuation|
          target_module.module_eval(<<-end_eval, __FILE__, __LINE__ + 1)
            def #{target}_with_deprecation#{punctuation}(*args, &block)
              ::ActiveSupport::Deprecation.warn(
                ::ActiveSupport::Deprecation.deprecated_method_warning(
                  :#{method_name},
                  #{options[method_name].inspect}),
                caller
              )
              send(:#{target}_without_deprecation#{punctuation}, *args, &block)
            end
          end_eval
        end
      end
    end
  end
end





ActiveSupport::Deprecation.maglev_persistable(true)
ActiveSupport::Dependencies.maglev_persistable(true)
ActiveSupport::Dependencies::Loadable.maglev_persistable(true)
ActiveSupport::Dependencies::Blamable.maglev_persistable(true)
ActiveSupport::Dependencies::ModuleConstMissing.maglev_persistable(true)
ActiveSupport::Concern.maglev_persistable(true)

MaglevSupport.maglev_persistable(true)
MaglevSupport::Concern.maglev_persistable(true)


Singleton.maglev_persistable(true)

(class << Singleton; self end).maglev_persistable(true)
(class << Singleton; self end)::SingletonClassMethods.maglev_persistable(true)

Pathname.maglev_persistable(true)

Psych.maglev_persistable(true)
Psych::Visitors.maglev_persistable(true)

I18n.maglev_persistable(true)
Forwardable.maglev_persistable(true)
Config.maglev_persistable(true)

Set.maglev_persistable(true)
# Path.maglev_persistable(true)

[Bundler, Gem, FileUtils, Rake, Psych, URI].each do |mod|
  mod.maglev_persistable(true)
end.each do |mod|
  mod.constants.each do |const|
    next if const.to_s == "Specification" and mod.name.to_s == "Bundler"
    moduleOrClass = mod.const_get(const)
    klass = moduleOrClass.class
    if klass == Class or klass == Module
      # nil.pause if moduleOrClass.name =~ /Dependency/
      moduleOrClass.maglev_persistable(true)
    end
  end
end

Bundler::RubygemsIntegration::Modern.maglev_persistable(true)
Bundler::Source::Rubygems.maglev_persistable(true)
Bundler::Source::Path.maglev_persistable(true)
Bundler::Source::Git.maglev_persistable(true)
Bundler::Resolver::SpecGroup.maglev_persistable(true)
Rake::PrivateReader::ClassMethods.maglev_persistable(true)


# I18n has anonymous modules so we need this:
(class << I18n; self end).included_modules.each do |mod| mod.maglev_persistable(true) end
I18n::Config.maglev_persistable(true)



require "base64"
Base64.maglev_persistable(true)
# # PP.maglev_persistable(true)

TSort.maglev_persistable(true)
