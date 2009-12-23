require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sequence do
  describe "new" do    
    it "should intialize the current value to whatever is passed in (or 1 by default)" do
      Sequence.new.current_value.should == 1
      Sequence.new(500).current_value.should == 500
    end
  end
  
  describe "next" do
    it "should return the next value in the sequence, then increment the current value" do
      s = Sequence.new
      s.next.should == 1
      s.current_value.should == 2
      s.next.should == 2
      s.current_value.should == 3
      
      s = Sequence.new(500)
      s.next.should == 500
      s.current_value.should == 501
      s.next.should == 501
      s.current_value.should == 502
    end
  end
end