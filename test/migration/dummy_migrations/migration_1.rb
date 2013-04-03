Migration.new(Time.utc(2013, 2, 1, 10, 0, 0, 0), "Creating a global variable $DUMMY") do
  def up
    $DUMMY = 1
  end
  def down
    $DUMMY = nil
  end
end