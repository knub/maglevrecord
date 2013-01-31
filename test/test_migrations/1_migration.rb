
Migration.new(Time.utc(2013, 2, 1, 10, 0, 0, 0), "Change book title") do
  def up
    Book.each do |book|
      book.title = "A new book title"
    end
  end
  def down
    Book.each do |book|
      book.title = "Back to old title"
    end
  end
end