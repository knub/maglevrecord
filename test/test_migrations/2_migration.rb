
Migration.new(Time.utc(2014, 2, 1, 10, 0, 0, 0), "Change book title again") do
  def up
    Book.each do |book|
      book.title = "A even newer book title"
    end
  end
  def down
    Book.each do |book|
      book.title = "A new book title"
    end
  end
end
