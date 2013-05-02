module MaglevRecord
  module RootedBase
    extend MaglevSupport::Concern
    include MaglevRecord::Base
    include MaglevRecord::RootedPersistence
    include MaglevRecord::Enumerable
  end
end