require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Symbol do 
  describe "plural?" do
    it "should report plural symbols as plural" do
      :apples.plural?.should == true
      :apple.plural?.should == false
    end
  end
  
  describe "singular?" do
    it "should report singular items as singular" do
      :apples.singular?.should == false
      :apple.singular?.should == true
    end
  end
end