require "set"

module MaglevRecord
  ##
  # Given a migration list (the desired applied migrations)
  # this class migrates to these state.
  # Therefore, it decides which migrations must be undone, and
  # which must be done and leaves the stone in the desired state.
  class Migrator

    # Make these two classes persistable, as we need them for storing
    # which migrations already ran.
    SortedSet.maglev_persistable
    Set.maglev_persistable

    def initialize(migration_list)
      @migration_list = migration_list
    end

    ##
    # Returns all migrations currently in the stone in the correct order.
    def migration_store
      Maglev::PERSISTENT_ROOT[:__migrations__] ||= SortedSet.new
    end

    ##
    # Applies the desired state of migrations.
    def up
      Maglev.abort_transaction
      to_do = @migration_list.reject do |mig|
       migration_store.include?(mig.id)
      end
      logger = MaglevRecordTransient::Logger
      logger.info("Already applied all migrations.") if to_do.empty?
      to_do.sort.each do |mig|
        logger.info("Doing '" + mig.name + "' from " + mig.timestamp.to_s)
        mig.do
        migration_store.add(mig.id)
      end
      Maglev.commit_transaction
    end
  end
end
