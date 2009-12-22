class Sequence
  attr_reader :current_value 
  
  def initialize
    @current_value = 0
  end
  
  def next
    @current_value += 1
  end
end