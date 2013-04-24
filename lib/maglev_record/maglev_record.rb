module MaglevRecord
  PERSISTENT_ROOT_KEY = :MaglevRecord

  def self.to_str
    to_s
  end
  def self.save
    Maglev.commit_transaction
  end

  def self.reset
    Maglev.abort_transaction
  end
end

# MaglevRecord.maglev_persistable

# ActiveModel.maglev_persistable(true)
# ActiveSupport.maglev_persistable(true)

# ActiveModel::Validations.maglev_persistable(true)
# ActiveModel::Errors.maglev_persistable(true)
# ActiveModel::Conversion.maglev_persistable(true)

# ActiveSupport::OrderedHash.maglev_persistable(true)
# ActiveSupport::Autoload.maglev_persistable(true)
# ActiveSupport::Inflector.maglev_persistable(true)
# ActiveSupport::Inflector::Inflections.maglev_persistable(true)


# ActiveSupport::Deprecation.maglev_persistable(true)
# ActiveSupport::Dependencies.maglev_persistable(true)
# ActiveSupport::Dependencies::Loadable.maglev_persistable(true)
# ActiveSupport::Dependencies::Blamable.maglev_persistable(true)
# ActiveSupport::Dependencies::ModuleConstMissing.maglev_persistable(true)
# ActiveSupport::Concern.maglev_persistable(true)

# MaglevSupport.maglev_persistable(true)
# MaglevSupport::Concern.maglev_persistable(true)


# Singleton.maglev_persistable(true)

# (class << Singleton; self end).maglev_persistable(true)
# (class << Singleton; self end)::SingletonClassMethods.maglev_persistable(true)

# Pathname.maglev_persistable(true)

# Psych.maglev_persistable(true)
# Psych::Visitors.maglev_persistable(true)
# Psych::Visitors::ToRuby.maglev_persistable(true)

# I18n.maglev_persistable(true)
# Forwardable.maglev_persistable(true)
# Config.maglev_persistable(true)

# Set.maglev_persistable(true)
# # Path.maglev_persistable(true)

# [Bundler, Gem, FileUtils, Rake, Psych, URI].each do |mod|
#   mod.maglev_persistable(true)
# end.each do |mod|
#   mod.constants.each do |const|
#     next if const.to_s == "Specification" and mod.name.to_s == "Bundler"
#     moduleOrClass = mod.const_get(const)
#     klass = moduleOrClass.class
#     if klass == Class or klass == Module
#       # nil.pause if moduleOrClass.name =~ /Dependency/
#       moduleOrClass.maglev_persistable(true)
#     end
#   end
# end

# Bundler::RubygemsIntegration::Modern.maglev_persistable(true)
# Bundler::Source::Rubygems.maglev_persistable(true)
# Bundler::Source::Path.maglev_persistable(true)
# Bundler::Source::Git.maglev_persistable(true)
# Bundler::Resolver::SpecGroup.maglev_persistable(true)
# Rake::PrivateReader::ClassMethods.maglev_persistable(true)
# Psych::Nodes.maglev_persistable(true)
# Psych::Nodes::Scalar.maglev_persistable(true)
# Psych::Nodes::Mapping.maglev_persistable(true)
# Psych::Nodes::Stream.maglev_persistable(true)
# Psych::Nodes::Document.maglev_persistable(true)
# Psych::LibPsych::ParserEvent.maglev_persistable(true)

# # I18n has anonymous modules so we need this:
# (class << I18n; self end).included_modules.each do |mod| mod.maglev_persistable(true) end
# I18n::Config.maglev_persistable(true)

# require "base64"
# Base64.maglev_persistable(true)

# TSort.maglev_persistable(true)

# # Started making things persistent
# ActiveSupport::Notifications.maglev_persistable
# ActiveSupport::Notifications::Fanout.maglev_persistable
