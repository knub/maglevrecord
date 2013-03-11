
module MaglevRecord
  module Persistence
    def persisted?
      !new_record?
    end

    def new_record?
      !committed?
    end
  end

  def self.save
    Maglev.commit_transaction
  end

  def self.reset
    Maglev.abort_transaction
  end

  def self.make_modules_persistent
    modules = [MaglevRecord]

    while (!modules.empty?)
      mod = modules.pop
      
      if !mod.maglev_persistable?
        mod.maglev_persistable
        modules += mod.constants.collect {|c| mod.const_get(c)}.find_all {|c| c.class == Module}
      end
    end
  end

end

