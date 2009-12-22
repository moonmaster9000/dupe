require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sequence do
  describe "new" do
    it "should initialize the current value of the sequence to zero" do
      Sequence.new.current_value.should == 0
    end
  end
  
  describe "next" do
    it "should increment the current value and return it" do
      s = Sequence.new
      s.current_value.should == 0
      s.next.should == 1
      s.current_value.should == 1
    end
  end
end