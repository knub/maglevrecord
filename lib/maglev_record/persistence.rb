require "active_support"

module MaglevRecord
  module Persistence
    extend ActiveSupport::Concern

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
end

