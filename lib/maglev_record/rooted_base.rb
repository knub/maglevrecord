require "active_support"
require "maglev_record/rooted_persistence"
require "maglev_record/enumerable"
require "maglev_record/base"

module MaglevRecord
  module RootedBase
    extend ActiveSupport::Concern

    included do
      include MaglevRecord::Base
      include MaglevRecord::RootedPersistence
    end
  end
end
