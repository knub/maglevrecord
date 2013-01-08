
Maglev.transient do
  class Memento
    attr_reader :backup
    def initialize
      @backup = {}
    end
  end
end