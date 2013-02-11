
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
      # This relies on the fact, that undone/done migrations
      # do nothing, if they already have been undone/done.
      to_undo = stone_migrations - @migration_list
      to_undo.sort.reverse.each do |mig|
        puts "Undoing '" + mig.name + "' from " + mig.timestamp
        mig.undo
        # Deleting old migrations, because we do not want them in the stone.
        # They can be applied again by checking out the appropriate commit in the vcs.
        mig.delete
        puts "=" * 50
      end
      to_do = @migration_list
      to_do.sort.each do |mig|
        puts "Doing '" + mig.name + "' from " + mig.timestamp
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
