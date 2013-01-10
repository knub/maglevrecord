# Maglev.persistent do
#   Object.remove_const(:NotSavedOnReset)
# end
# Maglev.commit_transaction

module MaglevRecord
  Maglev.transient do
    class ModelNotSavedOrReset
      @instance = self.new
      def self.new
        @instance
      end
    end
  end
end