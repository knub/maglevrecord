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
        @file_count = 0
  end

  def teardown
    # remove the directory
    FileUtils.remove_dir tempdir
  end

  def tempdir
    @tempdir
  end

  def write_to_file(content, file_path = File.join(tempdir, "x#{@file_count += 1}.rb"))
    File.open(file_path, 'w'){ |f| f.write content}
    file_path
  end

  # test the project configuration

  def test_tempdir_exists
    assert File.directory?(tempdir)
  end

end




