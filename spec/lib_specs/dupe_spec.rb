require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe do
  before do
    Dupe.reset
  end
  
  describe "reset" do
    it "should reset @models to an empty hash" do
      Dupe.models.length.should == 0
      Dupe.define :book do |attrs|
        attrs.title
        attrs.author
      end
      Dupe.models.length.should == 1
      Dupe.reset
      Dupe.models.should == {}
    end
  end
  
  describe "define" do
  
    # Dupe.define :model_name
    it "should accept a single symbol parameter" do
      proc {
        Dupe.define :book
      }.should_not raise_error
    end
  
    # Dupe.define :model_name do |attrs|
    #   attrs.attr1 'Default Value'
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
          attrs.author 'Anon'
          attrs.title 'Untitled'
        end
      }.should_not raise_error
    end
    
    it "should create a model and a schema with the desired definition" do
      Dupe.define :book do |attrs|
        attrs.author 'Anon'
        attrs.title 'Untitled' do |value|
          "transformed #{value}"
        end
      end
      
      Dupe.models.length.should == 1
      Dupe.models[:book].schema.attribute_templates[:author].name.should == :author
      Dupe.models[:book].schema.attribute_templates[:author].default.should == 'Anon'
      Dupe.models[:book].schema.attribute_templates[:title].name.should == :title
      Dupe.models[:book].schema.attribute_templates[:title].default.should == 'Untitled'
      Dupe.models[:book].schema.attribute_templates[:title].transformer.should be_kind_of(Proc)
      Dupe.models[:book].schema.attribute_templates[:title].transformer.call('value').should == 'transformed value'
    end
  end
 
end