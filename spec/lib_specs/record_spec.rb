require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Database::Record do
  describe "new" do
    it "should create an object that is a kind of Hashie::Mash" do
      Dupe::Database::Record.new.should be_kind_of(Hashie::Mash)
    end
  end
  
  describe "__model__" do
    
    it "should have a __model__ instance variable" do
      proc {Dupe::Database::Record.new.__model__}.should_not raise_error
    end
    
    it "should all you to set the __model_name__ instance variable" do
      r = Dupe::Database::Record.new
      proc {r.__model__ = :book}.should_not raise_error
      r.__model__.should == :book
    end
    
  end
  
end