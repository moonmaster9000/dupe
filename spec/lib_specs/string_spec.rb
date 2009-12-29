require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe String do 
  describe "plural?" do
    it "should report plural symbols as plural" do
      'apples'.plural?.should == true
      'apple'.plural?.should == false
    end
  end
  
  describe "singular?" do
    it "should report singular items as singular" do
      'apples'.singular?.should == false
      'apple'.singular?.should == true
    end
  end
  
  describe "indent" do
    it "should default the indentional level to 2 spaces" do
      'apples'.indent.should == "  apples"
    end
    
    it "should accept an indentional level" do
      'apples'.indent(4).should == "    apples"
    end
    
    it "should indent each line of the string" do
      "apples\noranges".indent(2).should == "  apples\n  oranges"
    end
  end
end