require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sequence do
  describe "new" do    
    it "should intialize the current value to whatever is passed in (or 1 by default)" do
      Sequence.new.current_value.should == 1
      Sequence.new(500).current_value.should == 500
    end

    it "should accept a block that takes a single parameter" do
      proc {Sequence.new 1, proc {}}.should raise_error(ArgumentError, "Your block must accept a single parameter")
      proc {Sequence.new 1, proc {|n| n}}.should_not raise_error
      proc {Sequence.new 1, proc {|n,m| n}}.should raise_error(ArgumentError, "Your block must accept a single parameter")
      s = Sequence.new 1, proc {|n| "email-#{n}@address.com"}
      s.current_value.should == 1
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

      s = Sequence.new 1, proc {|n| "email-#{n}@address.com"}
      s.next.should == "email-1@address.com"
      s.next.should == "email-2@address.com"
      s.current_value.should == 3
    end
  end
end
