require "tmpdir"
require 'test/unit'

#
# this test creates a temporary directory for the test
#

class TempDirTest < Test::Unit::TestCase
  def setup
    # make temporary directory
    # see http://ruby-doc.org/stdlib-2.0/libdoc/tmpdir/rdoc/Dir.html#method-c-mktmpdir
    @tempdir = Dir.mktmpdir
  end

  def teardown
    # remove the directory
    FileUtils.remove_dir tempdir
  end

  def tempdir
    @tempdir
  end

  # test the project configuration

  def test_tempdir_exists
    assert File.directory?(tempdir)
  end

end




