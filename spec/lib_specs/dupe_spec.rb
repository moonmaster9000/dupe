require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe do
  before do
    Dupe.reset
  end
  
  describe "ways to call" do
    describe "define" do
    
      # Dupe.define :model_name
      it "should accept a single symbol parameter" do
        proc {
          Dupe.define :book
        }.should_not raise_error
      end
    
      # Dupe.define :model_name => [:attr1, :attr2, :etc]
      it "should accept a simple hash like :model_name => [:attr1, :attr2, :etc]" do
        proc { 
          Dupe.define :book => [:author, :title, :label] 
        }.should_not raise_error
      end
    
    
      # Dupe.define :model_name => {:attr1 => 'default', :attr2 => 'default'}
      it  "should accept a more complicated hash like" + 
          " :model_name => {:attr1 => 'default', :attr2 => 'default'}" do
        proc { 
          Dupe.define :book => {:author => 'Anon', :title => 'Untitled'} 
        }.should_not raise_error
      end
    
    
      # Dupe.define :model_name do |attrs|
      #   attrs.attr1 = 'Default Value'
      #   attrs.attr2 do |value|
      #     'transformed value'
      #   end
      # end
      it "should accept a symbol plus a block (that accepts a single parameter)" do
        proc {
          Dupe.define :book do
          end
        }.should raise_error(
          ArgumentError,
          "Unknown Dupe.define parameter format. Please consult the API" + 
          " for information on how to use Dupe.define"
        )
      
        proc {
          Dupe.define :book do |attrs|
            attrs.author = 'Anon'
            attrs.title = 'Untitled'
          end
        }.should_not raise_error
      end
    end
  end
    
  describe "results of " do
    
    describe "define" do
      it "should create a Dupe::Model" do
        Dupe.define :book
        Dupe.models(:book).should_not be_nil
      end
    end
    
  end
  
  describe "reset" do
    it "should clear out all of Dupe's accumulated knowledge" do
      Dupe.define :book
      Dupe.models.should_not be_empty
      Dupe.reset
      Dupe.models.should be_empty
    end
  end
  
  describe "models method" do
    it "should return all models if no parameter is given" do
      Dupe.define :book
      Dupe.models.length.should == 1
    end
    
    it "should return a single model if requested" do
      Dupe.define :book
      Dupe.models(:book).should be_kind_of(Dupe::Model)
    end
  end
end