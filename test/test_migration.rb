require "test/unit"
require "maglev_record"


class EBook
  def self.name 
    :EBook
  end
  include MaglevRecord::Base
end

class MigrationTest #< Test::Unit::TestCase
  def setup
    @EBook = Class.new(EBook){
      attr_accessor :title
    }

    @books = [
      @EBook.new(:title => "Harry Potter and the Philosopher's stone"),
      @EBook.new(:title => "Harry Potter and the Chamber of Secrets"),
      @EBook.new(:title => "Harry Potter and the Prisoner of Azkaban"),
      @EBook.new(:title => "Harry Potter and the Goblet of Fire"),
      @EBook.new(:title => "Harry Potter and the Order of the Phoenix"),
      @EBook.new(:title => "Harry Potter and the Half-blood Prince"),
      @EBook.new(:title => "Harry Potter and the Deathly Hallows"),
      @EBook.new(:title => "The Magician's Guild")
    ]
    @books.each do |book|
      book.save
    end
  end

  def newMigration
    MaglevRecord::Migration.new(@EBook)
  end

  def book(no = 1)
    @books[no]
  end

  def test_teardown_and_setup_work
    assert_equal("Harry Potter and the Chamber of Secrets", book.title)
  end

  def test_add_field_author
    newMigration.add_attribute(:author, "J. K. Rohling")
    assert_equal("J. K. Rohling", book.author)
  end

  def test_add_field_author_with_nil
    newMigration.add_attribute(:author)
    assert_equal(nil, book.author)
  end

  def test_migrate_sold
    newMigration.add_attribute(:sold, 0)
    mig = newMigration
    mig.attribute(:sold) {
      up { |book|
        book.sold += 1
      }
      down { |book|
        book.sold -= 1
      }
    }
    @books.each { |book|
      assert_equal 1, book.sold
    }
  end
end
