require "test/unit"
require "maglev_record"

#
# obsolete test cases just for history
#

class TestMigrationApplication_apply # < Test::Unit::TestCase

  #
  # Applications are attributes of migrations:
  # migration.up, migration.down
  #
  # applications an be locked -> no more actions will be added then
  # this is helpful, if a migration is loaded twice: 
  #   the code will not run twice
  # 
  class A # < MaglevRecord::Migration::Application
  end

  def setup
    @a = A.new
  end

  def a
    @a
  end

  def test_execute_2_blocks_in_order
    s = ""
    a.do{s << "a"}
    a.do{s << "b"}
    a.execute
    assert_equal s, "ab"
  end

  def test_can_be_locked
    a.do{}
    a.lock
    a.do{raise IOError}
    a.execute # does not raise Error
  end

  def test_raise_error
    a.do{raise IOError, ''}
    assert_raise(IOError){
      a.execute
    }
  end

  def test_after_executing_application_is_locked
    a.execute
    assert a.locked?
  end

  def test_after_lock_is_locked
    a.lock
    assert a.locked?
  end

  def test_new_application_is_not_locked
    assert_equal a.locked?, false
  end


end
