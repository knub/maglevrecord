require 'bacon'
require 'maglev_record'

class ExampleStudent
  include Maglev::Base

  attr_accessible :name

  def initialize(name)
    name = name
  end
end

descibe 'ExampleStudent' do
  subject { ExampleStudent.new('Ferdinand') }

  it "should know its name" do
    subject.name.should equal('Ferdinand')
  end

end
