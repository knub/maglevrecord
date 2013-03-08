require "maglev_record/rooted_persistence"
require "maglev_record/base"

module MaglevRecord
  module RootedBase
    def self.included(base)
      base.include MaglevRecord::Base
      base.include MaglevRecord::RootedPersistence
    end
  end
end
