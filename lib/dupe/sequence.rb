class Sequence #:nodoc:
  attr_reader :current_value 
  
  def initialize(starting_at=1, sequencer=nil)
    @current_value = starting_at
    if sequencer && sequencer.arity != 1
      raise ArgumentError, "Your block must accept a single parameter"
    end
    @transformer = sequencer
  end
  
  def next
    @current_value += 1
    if @transformer
      @transformer.call(@current_value - 1)
    else
      @current_value - 1
    end
  end
end
