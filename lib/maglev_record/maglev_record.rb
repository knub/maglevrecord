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

with_methods = false

ActiveModel.maglev_persistable(with_methods)
ActiveSupport.maglev_persistable(with_methods)

ActiveModel::Validations.maglev_persistable(with_methods)
ActiveModel::Errors.maglev_persistable(with_methods)
ActiveModel::Conversion.maglev_persistable(with_methods)

ActiveSupport::OrderedHash.maglev_persistable(with_methods)
ActiveSupport::Autoload.maglev_persistable(with_methods)
ActiveSupport::Inflector.maglev_persistable(with_methods)
ActiveSupport::Inflector::Inflections.maglev_persistable(with_methods)

ActiveSupport::Deprecation.maglev_persistable(with_methods)
ActiveSupport::Dependencies.maglev_persistable(with_methods)
ActiveSupport::Dependencies::Loadable.maglev_persistable(with_methods)
ActiveSupport::Dependencies::Blamable.maglev_persistable(with_methods)
ActiveSupport::Dependencies::ModuleConstMissing.maglev_persistable(with_methods)
ActiveSupport::Concern.maglev_persistable(with_methods)

MaglevSupport.maglev_persistable(with_methods)
MaglevSupport::Concern.maglev_persistable(with_methods)

Singleton.maglev_persistable(with_methods)

(class << Singleton; self end).maglev_persistable(with_methods)
(class << Singleton; self end)::SingletonClassMethods.maglev_persistable(with_methods)

Pathname.maglev_persistable(with_methods)

Psych.maglev_persistable(with_methods)
Psych::Visitors.maglev_persistable(with_methods)
Psych::Visitors::ToRuby.maglev_persistable(with_methods)

I18n.maglev_persistable(with_methods)
Forwardable.maglev_persistable(with_methods)
Config.maglev_persistable(with_methods)

Set.maglev_persistable(with_methods)
# Path.maglev_persistable(with_methods)

finder = ModuleReferenceFinder.new
finder.find_referenced_modules_for(URI, Psych).each do |mod| mod.maglev_persistable end

[Bundler, Gem, FileUtils, Rake].each do |mod|
  mod.maglev_persistable(with_methods)
end.each do |mod|
  mod.constants.sort.each do |const|
    next if const.to_s == "Specification" and mod.name.to_s == "Bundler"
    begin
      moduleOrClass = mod.const_get(const)
    rescue NameError
      
    else
      klass = moduleOrClass.class
      if klass == Class or klass == Module
        # nil.pause if moduleOrClass.name =~ /Dependency/
        moduleOrClass.maglev_persistable(with_methods)
      end
    end
  end
end

Bundler::RubygemsIntegration::Modern.maglev_persistable(with_methods)
Bundler::Source::Rubygems.maglev_persistable(with_methods)
Bundler::Source::Path.maglev_persistable(with_methods)
Bundler::Source::Git.maglev_persistable(with_methods)
Bundler::Resolver::SpecGroup.maglev_persistable(with_methods)
Rake::PrivateReader::ClassMethods.maglev_persistable(with_methods)
Psych::Nodes.maglev_persistable(with_methods)
Psych::Nodes::Scalar.maglev_persistable(with_methods)
Psych::Nodes::Mapping.maglev_persistable(with_methods)
Psych::Nodes::Stream.maglev_persistable(with_methods)
Psych::Nodes::Document.maglev_persistable(with_methods)
Psych::LibPsych::ParserEvent.maglev_persistable(with_methods)

# I18n has anonymous modules so we need this:
(class << I18n; self end).included_modules.each do |mod| mod.maglev_persistable(with_methods) end
I18n::Config.maglev_persistable(with_methods)

require "base64"
Base64.maglev_persistable(with_methods)

TSort.maglev_persistable(with_methods)

# Started making things persistent
ActiveSupport::Notifications.maglev_persistable
ActiveSupport::Notifications::Fanout.maglev_persistable
