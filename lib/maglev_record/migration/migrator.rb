
module MaglevRecord
  class Migrator
    def initialize(migration_list)
      @migration_list = migration_list
    end


    def up
      to_undo = stone_migrations - @migration_list
      to_undo.sort.reverse.each do |mig|
        mig.undo
        mig.delete
      end
      to_do = @migration_list
      to_do.sort.each do |mig|
        mig.do
      end
    end

    def stone_migrations
      Migration.all.sort
    end
  end
end
