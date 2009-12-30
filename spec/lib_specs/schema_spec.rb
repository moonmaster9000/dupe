require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dupe::Model::Schema do
  describe "new" do
    it "should initialize attribute_templates to an empty array" do
      Dupe::Model::Schema.new.attribute_templates.should == {}
    end
  end
  
  describe "dynamic attribute_template creation methods" do
    before do
      @schema = Dupe::Model::Schema.new
    end
    
    describe "called with no parameters" do
      it "should create a new attribute template with no transformer and no default value" do
        @schema.title
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should be_nil
        @schema.attribute_templates[:title].transformer.should be_nil
      end
    end
    
    describe "called with a single parameter, but no block" do
      it "should create a new attribute template with a default value but no transformer" do
        @schema.title 'Untitled'
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should == 'Untitled'
        @schema.attribute_templates[:title].transformer.should be_nil
      end
    end
    
    describe "called with a block that accepts a parameter" do
      it "should create a new attribute template without a default value, but with a tranformer" do
        @schema.title {|dont_care| 'test'}
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should be_nil
        @schema.attribute_templates[:title].transformer.should be_kind_of(Proc)
      end
    end
    
    describe "called with a block that doesn't accept a parameter" do
      it "should create a new attribute template without a transformer, and with the block as the default value" do
        @schema.title { 'knock' * 3 }
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should be_kind_of(Proc)
        @schema.attribute_templates[:title].default.call.should == "knockknockknock"
        @schema.attribute_templates[:title].transformer.should be_nil
      end
    end
    
    describe "called with a block and a parameter" do
      it "should create a new attribute template with a default value AND with a tranformer" do
        @schema.title('Untitled') {|dont_care| 'test'}
        @schema.attribute_templates[:title].should be_kind_of(Dupe::Model::Schema::AttributeTemplate)
        @schema.attribute_templates[:title].name.should == :title
        @schema.attribute_templates[:title].default.should == 'Untitled'
        @schema.attribute_templates[:title].transformer.should be_kind_of(Proc)
      end
    end
    
  end
end