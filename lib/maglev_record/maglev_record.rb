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
ActiveSupport::OrderedHash.maglev_persistable
ActiveSupport::Dependencies.maglev_persistable
JSON.maglev_persistable
JSON::Ext.maglev_persistable
JSON::Ext::Generator.maglev_persistable
JSON::Ext::Generator::GeneratorMethods.maglev_persistable

Maglev.persistent do
  require "pp"
end

require "base64"
Base64.maglev_persistable
# PP.maglev_persistable
