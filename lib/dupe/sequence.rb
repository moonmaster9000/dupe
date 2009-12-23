class Sequence
  attr_reader :current_value 
  
  def initialize(starting_at=1)
    @current_value = starting_at
  end
  
  def next
    @current_value += 1
    @current_value - 1
  end
end