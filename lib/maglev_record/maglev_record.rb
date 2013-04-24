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
