require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Model do
  describe "new" do
    it "should require a model name" do
      proc { Dupe::Model.new }.should raise_error(ArgumentError)
    end
    
    it "should set the model name to what was passed in during initialization" do
      m = Dupe::Model.new :book
      m.name.should == :book
    end
    
    it "should initialize an empty schema" do
      m = Dupe::Model.new :book
      m.schema.should be_kind_of(Dupe::Model::Schema)
    end
  end
  
  describe "define" do
    describe "when passed a proc" do
      it "should pass that proc off to it's schema" do
        m = Dupe::Model.new :book
        m.schema.should_receive(:method_missing)
      end
    end
  end
end