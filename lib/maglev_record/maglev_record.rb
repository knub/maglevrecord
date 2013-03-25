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
ActiveModel.maglev_persistable
ActiveSupport.maglev_persistable
ActiveModel::Validations.maglev_persistable
ActiveModel::Errors.maglev_persistable
ActiveModel::Conversion.maglev_persistable
ActiveSupport::OrderedHash.maglev_persistable
ActiveSupport::Deprecation.maglev_persistable(true)
ActiveSupport::Concern.maglev_persistable(true)
MaglevSupport.maglev_persistable(true)
MaglevSupport::Concern.maglev_persistable(true)

Gem.maglev_persistable(true)
Gem::Deprecate.maglev_persistable(true)
Gem::Platform.maglev_persistable(true)
Gem::PathSupport.maglev_persistable(true)
Gem::Specification.maglev_persistable(true)

I18n.maglev_persistable(true)
I18n::Config.maglev_persistable(true)

Psych.maglev_persistable(true)
Psych::LibPsych.maglev_persistable(true)

require "base64"
Base64.maglev_persistable
# PP.maglev_persistable
