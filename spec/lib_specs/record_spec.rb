require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Database::Record do
  describe "new" do
    it "should create an object that is a kind of Hash" do
      Dupe::Database::Record.new.should be_kind_of(Hash)
    end
  end
  
  describe "id" do
    it "should allow us to set the record id (and not the object id)" do
      d = Dupe::Database::Record.new
      d.id.should == nil
      d[:id].should == nil
      d.id = 1
      d.id.should == 1
      d[:id].should == 1
    end
  end
  
  describe "method_missing" do
    it "should allow us to access hash keys as if they were object attributes" do
      d = Dupe::Database::Record.new
      d[:some_key].should == nil
      d.some_key.should == nil
      d.some_key = 1
      d.some_key.should == 1
      d[:some_key].should == 1
      d[:another_key] = 2
      d.another_key.should == 2
      d[:another_key].should == 2
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