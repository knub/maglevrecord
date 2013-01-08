
module MaglevRecord
  module Persistence
    extend ActiveSupport::Concern

    module InstanceMethods
      def persisted?
        !new_record?
      end

      def new_record?
      	!committed?
      end
    end
  end
end

