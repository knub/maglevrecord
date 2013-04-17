Migration.new(Time.utc(2015, 2, 1, 10, 0, 0, 0), "Adding 1 to $DUMMY") do
  def up
    $DUMMY += 1
  end
  def down
    $DUMMY -= 1
  end
end