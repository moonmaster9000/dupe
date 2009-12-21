require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe do
  
  describe "define" do
    it "should require a symbol parameter" do
      proc { Dupe.define }.should raise_error(
        ArgumentError, 
        "You must pass the name of the model you want to define"
      )
    end
  end
  
end