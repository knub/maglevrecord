require "maglev_record"
require "more_asserts"

class MySnapshotableClass
  include MaglevRecord::Snapshotable
end

class MySnapshotableSubclass < MySnapshotableClass
end

class MyNotSnapshotableClass
end

class SnapshotableTest < Test::Unit::TestCase

  def self.startup
    @snapshotable_classes = MaglevRecord::Snapshotable.snapshotable_classes
  end

  def self.snapshotable_classes
    @snapshotable_classes
  end

  def snapshotable_classes
    self.class.snapshotable_classes
  end

  def test_includes_MySnapshotableClass
    assert_include? snapshotable_classes, MySnapshotableClass
  end

  def test_deas_not_include_Bases
    assert_not_include? snapshotable_classes, MaglevRecord::Base
    assert_not_include? snapshotable_classes, MaglevRecord::RootedBase
  end

  def test_does_not_include_some_other_class
    assert_not_include? snapshotable_classes, MyNotSnapshotableClass
  end

  def test_includes_subclass
    assert_include? snapshotable_classes, MySnapshotableSubclass
  end

end
