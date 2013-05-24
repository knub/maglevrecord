module MaglevRecord
  ##
  # Given a migration list (the desired applied migrations)
  # this class migrates to these state.
  # Therefore, it decides which migrations must be undone, and
  # which must be done and leaves the stone in the desired state.
  class Migrator

    MIGRATION_KEY = :__migrations__

    def initialize(migration_list)
      @migration_list = migration_list
      @non_displaying_logger = Logger.new(STDOUT)
      @non_displaying_logger.level = Logger::FATAL
    end

    ##
    # Returns all migrations currently in the stone in the correct order.
    def migration_store
      Maglev::PERSISTENT_ROOT[MIGRATION_KEY] ||= []
    end

    def migrations_todo
      @migration_list.reject do |mig|
        migration_store.include?(mig.id)
      end
    end

    def up?(logger = @non_displaying_logger)
      # todo: test
      migrations_todo.sort.each do |mig|
        logger.info("to do: '" + mig.name + "' from " + mig.timestamp.to_s)
      end
      logger.info("Already applied all migrations.") if migrations_todo.empty?
    end

    ##
    # Applies the desired state of migrations.
    def up(logger = @non_displaying_logger)
      Maglev.abort_transaction
      to_do = migrations_todo
      logger.info("Already applied all migrations.") if to_do.empty?
      to_do.sort.each do |mig|
        mig.logger = logger
        logger.info("Doing '" + mig.name + "' from " + mig.timestamp.to_s)
        mig.do
        migration_store << mig.id
      end
      Maglev.commit_transaction
    end

    def self.for_directory(directory)
      loader = MigrationLoader.new
      loader.load_directory(directory)
      new(loader.migration_list)
    end
  end
end
