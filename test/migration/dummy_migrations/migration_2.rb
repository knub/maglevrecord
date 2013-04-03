Migration.new(Time.utc(2014, 2, 1, 10, 0, 0, 0), "Multiplying $DUMMY by 2") do
  def up
    $DUMMY *= 2
  end
  def down
    $DUMMY /= 2
  end
end