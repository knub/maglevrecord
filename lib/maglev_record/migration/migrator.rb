
module MaglevRecord
  ##
  # Given a migration list (the desired applied migrations)
  # this class migrates to these state.
  # Therefore, it decides which migrations must be undone, and
  # which must be done and leaves the stone in the desired state.
  class Migrator
    def initialize(migration_list)
      @migration_list = migration_list
    end

    ##
    # Applies the desired state of migrations.
    def up
      to_do = @migration_list
      to_do.sort.each do |mig|
        Logger.info("Doing '" + mig.name + "' from " + mig.timestamp.to_s)
        mig.do
      end
    end

    ##
    # Returns all migrations currently in the stone in the correct order.
    def stone_migrations
      Migration.all.sort
    end
  end
end
