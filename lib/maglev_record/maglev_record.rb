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
require "base64"
Base64.maglev_persistable
