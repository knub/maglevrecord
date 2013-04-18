require "more_asserts"
require "fileutils"
require "tmpdir"

PROJECT_TMP_DIRECTORY =

#
# this test creates a temporary directory for the test
#
class TempdirTest < Test::Unit::TestCase

  class << self
    def startup
      # make temporary directory
      # see http://ruby-doc.org/stdlib-2.0/libdoc/tmpdir/rdoc/Dir.html#method-c-mktmpdir
      @tempdir = Dir.mktmpdir
    end

    def shutdown
      # remove the directory.
      FileUtils.remove_entry tempdir
    end

    def tempdir
      @tempdir
    end
  end

  def tempdir
    self.class.tempdir
  end

  def test_tempdir_exists
    File.directory? tempdir
  end

end






