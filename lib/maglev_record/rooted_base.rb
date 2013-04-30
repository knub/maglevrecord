module MaglevRecord
  module RootedBase
    extend MaglevSupport::Concern
    include MaglevRecord::Base
    include MaglevRecord::RootedPersistence

    redo_include ::Enumerable
  end
end