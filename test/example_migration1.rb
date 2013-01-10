

#
# set the author
#
class ExampleMigration1 < MaglevRecord::Migration
  
  timestamp = 1
  ofClass = MigrationBook

  def up
    MigrationBook.each { |book|
      book.author = "author" if book.author.nil?
    }
  end

  def down

  end

end

class ExampleMigration2 < MaglevRecord::Migration
  
  timestamp = 2
  ofClass = MigrationBook

  def up
    MigrationBook.each{ |book|
      book.comments = [] if book.comments.nil?
    }
  end

  def down

  end

end

class ExampleMigration3 < MaglevRecord::Migration

  timestamp = 3
  ofClass = MigrationBook

  def up
    MigrationBook.each { |book|
      book.title << " in practice"
    }
  end

  def down
    MigrationBook.each { |book|
      book.title = book.title[-" in practice".size..0]
    }
  end

end













