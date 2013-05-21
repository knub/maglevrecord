require "more_asserts"

class FileSystemSnapshotTest < Test::Unit::TestCase

  def test_snapshot_a_class
    file 1, "class SomeClass;end"
    s = snapshot_from_file
    assert_includes? s.classes, SomeClass
  end

end






