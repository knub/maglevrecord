module MaglevRecord
  class Error < RuntimeError
  end

  class InvalidOperationError < Error
  end

  class IrreversibleMigration < Error
  end

  class NoMigrationReadError < Error
  end
end
