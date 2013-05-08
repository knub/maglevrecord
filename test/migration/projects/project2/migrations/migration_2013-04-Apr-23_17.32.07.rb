require "maglev_record/migration"
require "time"

MaglevRecord::Migration.new(Time.parse('Tue Apr 23 17:32:07 +0000 2013'), 'fill in description here') do

  def up
    #rename_class TestModel::C, :D
  end

  def down
    # put the code that reverses the code in up here 
    # remove the next line that throws he error 
    raise IrreversibleMigration, 'The migration has no downcode'
  end

end
