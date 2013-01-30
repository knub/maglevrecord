require "test/unit"
require "maglev_record"

require "example_model"

class MigrationTest #< Test::Unit::TestCase
  Migration = MaglevRecord::Migration
  def setup
    @books = [
      Book.new(:title => "Harry Potter and the Philosopher's stone"),
      Book.new(:title => "Harry Potter and the Chamber of Secrets"),
      Book.new(:title => "Harry Potter and the Prisoner of Azkaban"),
      Book.new(:title => "Harry Potter and the Goblet of Fire"),
      Book.new(:title => "Harry Potter and the Order of the Phoenix"),
      Book.new(:title => "Harry Potter and the Half-blood Prince"),
      Book.new(:title => "Harry Potter and the Deathly Hallows"),
      Book.new(:title => "The Magician's Guild")
    ]
    @books.each do |book|
      book.save
    end
  end

  def newMigration
    Migration.new(Time.now)
  end

  # Access one of the books via index
  def book(index = 1)
    @books[index]
  end

  def test_add_field_author
    newMigration.add_attribute(:writer, "J. K. Rohling")
    assert_equal("J. K. Rohling", book.writer)
  end

  def test_add_field_author_with_nil
    newMigration.add_attribute(:author)
    assert_equal(nil, book.author)
  end
end
