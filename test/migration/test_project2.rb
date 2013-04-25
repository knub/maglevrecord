require "migration/test_project"

class MigrationProject2 < ProjectTest

  def setup
    @project_name = 'project2'
    super
  end

  def test_can_migrate_up
    #o = rake('migrate:up')
    #Maglev.abort_transaction
    s = rails_c('')
    puts "-" * 20
    puts project_source_directory
    puts project_directory
    puts s
#output = IO.popen('export MAGLEV_OPTS="-W0";bundle exec rails c'){|f| 
#s = line = ''
#    while not line.nil?
#    s += line
#     line = f.gets
#  end
#    output = s
#  }
#   p output
  end

  def teardown

  end

end
