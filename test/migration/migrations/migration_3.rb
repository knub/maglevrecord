Migration.new(Time.utc(2015, 2, 1, 10, 0, 0, 0), "Change book title to most recent one") do
  def up
    # RootedBook.each do |book|
    #   book.title = "The most recent book title"
    # end
  end
  def down
    # RootedBook.each do |book|
    #   book.title = "A even newer book title"
    # end
  end
end